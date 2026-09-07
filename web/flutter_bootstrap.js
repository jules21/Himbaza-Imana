{{flutter_js}}
{{flutter_build_config}}

// Keep the rendering engine on our origin so it is available offline too.
// The custom PWA worker in index.html owns caching; do not register Flutter's
// generated worker over the same scope.
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" }
});
