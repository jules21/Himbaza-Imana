{{flutter_js}}
{{flutter_build_config}}

// Use our worker instead of Flutter's generated worker. The build-time token
// changes whenever Flutter's asset graph changes, forcing an update check.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerUrl: 'pwa_service_worker.js?v=' + {{flutter_service_worker_version}},
    serviceWorkerVersion: {{flutter_service_worker_version}},
    timeoutMillis: 10000,
  },
});
