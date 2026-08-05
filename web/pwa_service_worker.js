const CACHE_VERSION = new URL(self.location.href).searchParams.get('v') || 'dev';
const SHELL_CACHE = `indirimbo-shell-${CACHE_VERSION}`;
const RUNTIME_CACHE = `indirimbo-runtime-${CACHE_VERSION}`;

// Keep this list small: it is the minimum shell required to start offline.
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './flutter_bootstrap.js',
  './main.dart.js',
  './canvaskit/canvaskit.js',
  './canvaskit/canvaskit.wasm',
  './canvaskit/chromium/canvaskit.js',
  './canvaskit/chromium/canvaskit.wasm',
  './assets/AssetManifest.bin.json',
  './assets/FontManifest.json',
  './assets/fonts/MaterialIcons-Regular.otf',
  './assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  './assets/assets/bride_songs.json',
  './assets/assets/bride_songsx.json',
  './assets/assets/hymns_praise_songs.json',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(SHELL_CACHE)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((key) =>
          (key.startsWith('indirimbo-shell-') || key.startsWith('indirimbo-runtime-')) &&
          key !== SHELL_CACHE && key !== RUNTIME_CACHE
        ).map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  // Documents are network-first so deployments become visible immediately,
  // with the cached app shell as the offline fallback.
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          const copy = response.clone();
          caches.open(RUNTIME_CACHE).then((cache) => cache.put(event.request, copy));
          return response;
        })
        .catch(async () =>
          (await caches.match(event.request)) || (await caches.match('./index.html'))
        )
    );
    return;
  }

  // Versioned Flutter assets are cache-first; new versions receive new URLs or
  // a new worker cache version. A miss is cached at runtime.
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request).then((response) => {
      if (!response || response.status !== 200 || response.type === 'opaque') return response;
      const copy = response.clone();
      event.waitUntil(caches.open(RUNTIME_CACHE).then((cache) => cache.put(event.request, copy)));
      return response;
    }))
  );
});
