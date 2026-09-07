// Filled from the production output by tool/prepare_pwa.mjs.
const CACHE_VERSION = "indirimbo-__BUILD_HASH__";
const APP_SHELL = /* __APP_SHELL__ */ [];
const APP_CACHE = `${CACHE_VERSION}-shell`;
const scopeUrl = new URL(self.registration.scope);
const scopedUrl = (path) => new URL(path, scopeUrl).href;

self.addEventListener("install", (event) => {
  event.waitUntil((async () => {
    if (!APP_SHELL.length) throw new Error("Run tool/prepare_pwa.mjs after building Flutter.");
    const cache = await caches.open(APP_CACHE);
    // Activate only after all code, renderer, fonts and songs are cached.
    await cache.addAll(APP_SHELL.map((path) => new Request(scopedUrl(path), { cache: "reload" })));
    // Existing app windows keep their matching build until they close.
  })());
});

self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    for (const name of await caches.keys()) {
      if (name.startsWith("indirimbo-") && name !== APP_CACHE) await caches.delete(name);
    }
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== "GET" || url.origin !== scopeUrl.origin || !url.pathname.startsWith(scopeUrl.pathname)) return;
  event.respondWith((async () => {
    const cache = await caches.open(APP_CACHE);
    const cached = request.mode === "navigate"
      ? await cache.match(scopedUrl("index.html"))
      : await cache.match(request, { ignoreSearch: true });
    return cached || fetch(request);
  })());
});
