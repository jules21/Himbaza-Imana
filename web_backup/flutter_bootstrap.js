{{flutter_js}}
{{flutter_build_config}}

// Use our worker instead of Flutter's generated worker. The build-time token
// changes whenever Flutter's asset graph changes, forcing an update check.
_flutter.loader.load({
  // Keep the rendering engine on this origin so our service worker can cache
  // it. Flutter otherwise downloads CanvasKit from gstatic.com, which makes a
  // cold reload fail when the browser is offline.
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
  serviceWorkerSettings: {
    serviceWorkerUrl: 'pwa_service_worker.js?v=' + {{flutter_service_worker_version}},
    serviceWorkerVersion: {{flutter_service_worker_version}},
    timeoutMillis: 10000,
  },
});
