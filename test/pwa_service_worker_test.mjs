import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import vm from 'node:vm';
import test from 'node:test';

const source = await readFile(new URL('../build/web/pwa_service_worker.js', import.meta.url), 'utf8');
const indexSource = await readFile(new URL('../build/web/index.html', import.meta.url), 'utf8');
const manifest = JSON.parse(await readFile(new URL('../build/web/manifest.json', import.meta.url), 'utf8'));
const bootstrapTemplate = await readFile(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8');
function worker(scope, failedPath = '') {
  const handlers = {};
  const stores = new Map();
  let offline = false;
  const network = async (request) => {
    const url = typeof request === 'string' ? request : request.url;
    if (offline || (failedPath && url.endsWith(failedPath))) throw new Error('offline');
    const file = decodeURIComponent(url.slice(scope.length));
    return new Response(await readFile(new URL(`../build/web/${file}`, import.meta.url)));
  };
  const caches = {
    keys: async () => [...stores.keys()],
    delete: async (key) => stores.delete(key),
    open: async (key) => {
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
    self: { registration: { scope }, clients: { claim: async () => {} },
      addEventListener: (name, handler) => { handlers[name] = handler; } },
  });
  return {
    offline: () => { offline = true; },
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
    assert.equal(app.cachedUrls().some((url) => url.endsWith('.symbols')), false);
    assert.equal(app.cachedUrls().some((url) => url.includes('/skwasm')), false);
    app.offline();
    for (const route of ['', 'lyrics/42?source=home']) {
      assert.match(await (await app.fetch(route, 'navigate')).text(), /<html>/);
    }
    for (const file of ['flutter_bootstrap.js', 'main.dart.js?v=1', 'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm', 'assets/assets/Bride_songs.json', 'assets/assets/hymns_praise_songs.json']) {
      const response = await app.fetch(file);
      assert.equal(response.status, 200, file);
      assert.ok((await response.arrayBuffer()).byteLength > 0, file);
    }
  });
}
test('incomplete download fails installation', async () => {
  const app = worker('https://example.test/', 'main.dart.js');
  await assert.rejects(app.lifecycle('install'), /offline/);
});

test('iOS standalone shell matches the app bar and starts caching before Flutter', () => {
  assert.match(indexSource, /theme-color" content="#37474F"/);
  assert.match(indexSource, /apple-mobile-web-app-capable" content="yes"/);
  assert.match(indexSource, /apple-mobile-web-app-status-bar-style" content="black-translucent"/);
  assert.equal(manifest.theme_color, '#37474F');
  assert.equal(manifest.background_color, '#37474F');
  assert.ok(bootstrapTemplate.indexOf('await prepareOfflineSupport()') < bootstrapTemplate.indexOf('await _flutter.loader.load'));
});
