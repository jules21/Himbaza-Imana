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
    // Smaller batches are more reliable on iOS than one large concurrent fetch.
    const requests = APP_SHELL.map((path) => new Request(scopedUrl(path), { cache: "reload" }));
    for (let index = 0; index < requests.length; index += 8) {
      await cache.addAll(requests.slice(index, index + 8));
    }
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
    if (request.mode === "navigate") {
      try {
        // Prefer the current document while online. This avoids replaying a
        // stale or partially persisted shell after an iOS home-screen reload.
        return await fetch(request);
      } catch (networkError) {
        try {
          const cache = await caches.open(APP_CACHE);
          const cached = await cache.match(scopedUrl("index.html"));
          if (cached) return cached;
        } catch (cacheError) {
          console.warn("PWA offline shell unavailable:", cacheError);
        }
        throw networkError;
      }
    }

    try {
      const cache = await caches.open(APP_CACHE);
      const cached = await cache.match(request, { ignoreSearch: true });
      if (cached) return cached;
    } catch (error) {
      // Cache Storage can be evicted or denied, especially on iOS. Never turn
      // that storage failure into a failed online navigation.
      console.warn("PWA cache read failed; using the network:", error);
    }
    return fetch(request);
  })());
});
