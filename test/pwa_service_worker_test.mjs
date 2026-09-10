import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import vm from 'node:vm';
import test from 'node:test';

const source = await readFile(new URL('../build/web/pwa_service_worker.js', import.meta.url), 'utf8');
const indexSource = await readFile(new URL('../build/web/index.html', import.meta.url), 'utf8');
const manifest = JSON.parse(await readFile(new URL('../build/web/manifest.json', import.meta.url), 'utf8'));
const bootstrapTemplate = await readFile(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8');
function worker(scope, failedPath = '', userAgent = '') {
  const handlers = {};
  const stores = new Map();
  let offline = false;
  let cacheUnavailable = false;
  let networkRequests = 0;
  let skippedWaiting = false;
  const network = async (request) => {
    networkRequests += 1;
    const url = typeof request === 'string' ? request : request.url;
    if (offline || (failedPath && url.endsWith(failedPath))) throw new Error('offline');
    const file = typeof request !== 'string' && request.mode === 'navigate'
      ? 'index.html'
      : decodeURIComponent(url.slice(scope.length));
    return new Response(await readFile(new URL(`../build/web/${file}`, import.meta.url)));
  };
  const caches = {
    keys: async () => [...stores.keys()],
    delete: async (key) => stores.delete(key),
    open: async (key) => {
      if (cacheUnavailable) throw new Error('cache unavailable');
      if (!stores.has(key)) stores.set(key, new Map());
      const store = stores.get(key);
      return {
        addAll: async (requests) => {
          const responses = await Promise.all(requests.map(network));
          requests.forEach((request, i) => store.set(request.url, responses[i]));
        },
        match: async (request, options = {}) => {
          const url = new URL(typeof request === 'string' ? request : request.url);
          if (options.ignoreSearch) url.search = '';
          return store.get(url.href)?.clone();
        },
      };
    },
  };
  vm.runInNewContext(source, {
    URL, Request, Response, caches, fetch: network,
    self: { registration: { scope }, navigator: { userAgent },
      clients: { claim: async () => {} },
      skipWaiting: async () => { skippedWaiting = true; },
      addEventListener: (name, handler) => { handlers[name] = handler; } },
  });
  return {
    offline: () => { offline = true; },
    makeCacheUnavailable: () => { cacheUnavailable = true; },
    networkRequests: () => networkRequests,
    skippedWaiting: () => skippedWaiting,
    cachedUrls: () => [...stores.values()].flatMap((store) => [...store.keys()]),
    lifecycle: (name) => new Promise((resolve, reject) => handlers[name]({ waitUntil: (promise) => promise.then(resolve, reject) })),
    fetch: (relative, mode = 'cors') => {
      let response;
      handlers.fetch({ request: { url: new URL(relative, scope).href, method: 'GET', mode }, respondWith: (promise) => { response = promise; } });
      return response;
    },
  };
}
for (const scope of ['https://example.test/', 'https://example.test/Himbaza-Imana/']) {
  test(`cold offline launch and unvisited songs at ${scope}`, async () => {
    const app = worker(scope);
    await app.lifecycle('install');
    await app.lifecycle('activate');
    assert.ok(app.cachedUrls().length > 0);
    assert.equal(app.skippedWaiting(), true);
    assert.equal(app.cachedUrls().some((url) => url.endsWith('.symbols')), false);
    assert.equal(app.cachedUrls().some((url) => url.includes('/skwasm')), false);
    assert.equal(app.cachedUrls().some((url) => url.includes('no_sleep.js')), false);
    app.offline();
    for (const route of ['', 'lyrics/42?source=home']) {
      assert.match(await (await app.fetch(route, 'navigate')).text(), /<html>/);
    }
    for (const file of ['flutter_bootstrap.js', 'main.dart.js?v=1', 'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm', 'assets/assets/Bride_songs.json', 'assets/assets/nyimbo_za_wokovu.json', 'assets/assets/hymns_praise_songs.json']) {
      const response = await app.fetch(file);
      assert.equal(response.status, 200, file);
      assert.ok((await response.arrayBuffer()).byteLength > 0, file);
    }
  });
}
test('iOS install excludes the Chromium-only CanvasKit variant', async () => {
  const app = worker(
    'https://example.test/',
    '',
    'Mozilla/5.0 (iPhone) AppleWebKit/605.1.15 Version/18.0 Mobile Safari/604.1',
  );
  await app.lifecycle('install');
  await app.lifecycle('activate');
  assert.equal(
    app.cachedUrls().some((url) => url.includes('canvaskit/chromium/')),
    false,
  );
  app.offline();
  assert.match(await (await app.fetch('', 'navigate')).text(), /<html>/);
  assert.equal((await app.fetch('canvaskit/canvaskit.wasm')).status, 200);
});
test('incomplete download fails installation', async () => {
  const app = worker('https://example.test/', 'main.dart.js');
  await assert.rejects(app.lifecycle('install'), /offline/);
});

test('cache storage failure falls back to the network', async () => {
  const app = worker('https://example.test/');
  await app.lifecycle('install');
  await app.lifecycle('activate');
  app.makeCacheUnavailable();
  assert.ok((await (await app.fetch('version.json')).arrayBuffer()).byteLength > 0);
});

test('online navigation bypasses the cached shell', async () => {
  const app = worker('https://example.test/');
  await app.lifecycle('install');
  await app.lifecycle('activate');
  const beforeNavigation = app.networkRequests();
  assert.match(await (await app.fetch('lyrics/42', 'navigate')).text(), /<html>/);
  assert.equal(app.networkRequests(), beforeNavigation + 1);
});

test('iOS standalone shell uses stable viewport sizing and caches before Flutter', () => {
  assert.match(indexSource, /theme-color" content="#37474F"/);
  assert.match(indexSource, /apple-mobile-web-app-capable" content="yes"/);
  assert.match(indexSource, /apple-mobile-web-app-status-bar-style" content="black"/);
  assert.doesNotMatch(indexSource, /viewport-fit=cover/);
  assert.equal(manifest.display, 'standalone');
  assert.equal(manifest.theme_color, '#37474F');
  assert.equal(manifest.background_color, '#37474F');
  assert.match(bootstrapTemplate, /await waitForActivation\(registration\)/);
  assert.doesNotMatch(bootstrapTemplate, /OFFLINE_READY_TIMEOUT_MS/);
  assert.ok(bootstrapTemplate.indexOf('await prepareOfflineSupport()') < bootstrapTemplate.indexOf('await _flutter.loader.load'));
});
