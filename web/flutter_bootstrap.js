{{flutter_js}}
{{flutter_build_config}}

const OFFLINE_READY_TIMEOUT_MS = 15000;

async function prepareOfflineSupport() {
  if (!("serviceWorker" in navigator)) return;

  const registration = await navigator.serviceWorker.register(
    "pwa_service_worker.js",
    { scope: "./", updateViaCache: "none" }
  );

  // A first launch must finish caching before the user can install and reopen
  // the app offline. Existing installations resolve this immediately.
  await Promise.race([
    navigator.serviceWorker.ready,
    new Promise((resolve) => setTimeout(resolve, OFFLINE_READY_TIMEOUT_MS))
  ]);
  console.log("PWA service worker registered:", registration.scope);
}

(async () => {
  try {
    await prepareOfflineSupport();
  } catch (error) {
    // Online startup should still work if the browser rejects PWA support.
    console.error("PWA service worker registration failed:", error);
  }

  // Keep the rendering engine on our origin so it is available offline too.
  await _flutter.loader.load({
    config: { canvasKitBaseUrl: "canvaskit/" }
  });
})();
