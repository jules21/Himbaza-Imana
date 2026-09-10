{{flutter_js}}
{{flutter_build_config}}

function waitForActivation(registration) {
  const worker = registration.installing || registration.waiting;
  if (!worker || worker.state === "activated") return Promise.resolve();

  return new Promise((resolve, reject) => {
    const onStateChange = () => {
      if (worker.state === "activated") {
        worker.removeEventListener("statechange", onStateChange);
        resolve();
      } else if (worker.state === "redundant") {
        worker.removeEventListener("statechange", onStateChange);
        reject(new Error("PWA service worker installation failed."));
      }
    };
    worker.addEventListener("statechange", onStateChange);
    onStateChange();
  });
}

async function prepareOfflineSupport() {
  if (!("serviceWorker" in navigator)) return;

  const registration = await navigator.serviceWorker.register(
    "pwa_service_worker.js",
    { scope: "./", updateViaCache: "none" }
  );

  // Home Screen apps have storage isolated from Safari on iOS. Do not show the
  // app until this standalone instance has finished caching its own shell.
  await waitForActivation(registration);
  await navigator.serviceWorker.ready;

  if (navigator.storage?.persist) {
    try {
      await navigator.storage.persist();
    } catch (_) {
      // Persistence is a best-effort hint; the completed cache still works.
    }
  }
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
