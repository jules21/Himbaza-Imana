# Indirimbo PWA implementation

## 1. Install metadata

`web/manifest.json` defines the install name, stable app id/scope, standalone
display mode, Kinyarwanda language, colors, and regular/maskable icons.
`web/index.html` links the manifest and supplies matching browser/iOS metadata.

Keep the 192x192 and 512x512 PNG files in `web/icons/`. Installability must be
tested through HTTPS (localhost is accepted for local development).

## 2. Offline caching

`web/flutter_bootstrap.js` tells Flutter's loader to register
`web/pwa_service_worker.js`. Flutter replaces the service-worker-version token
at build time, so a deployment activates a fresh cache.

The worker uses:

- network-first for page navigations, falling back to cached `index.html`;
- cache-first for same-origin Flutter code, fonts, images, and app assets;
- versioned shell/runtime caches, with old versions deleted on activation.

Add any file that is absolutely required on first offline launch to `APP_SHELL`.
Do not cache authenticated API responses without designing per-user eviction.

## 3. Custom install banner

`PwaInstallService` uses a conditional export. Mobile/desktop builds receive a
no-op implementation, while web listens for `beforeinstallprompt`, calls
`preventDefault()`, and retains the event until the user presses Install.
`PwaInstallBanner` is mounted through `MaterialApp.builder` in `lib/main.dart`.

Chrome/Edge fire this event only when their installability checks pass. iOS
Safari does not expose it; iOS users must use Share > Add to Home Screen.

## 4. Responsive shell

`ResponsiveAppShell` uses `LayoutBuilder` and these content caps:

- phone (<700px): full width;
- tablet (700-1199px): maximum 840px;
- desktop (1200px+): maximum 1100px.

For screens that benefit from a true master/detail UI, add a second breakpoint
inside that screen and render a `Row` with navigation and content panes.

## 5. Production builds

From the repository root:

```powershell
flutter pub get
flutter build web --release --web-renderer html --base-href /
```

HTML has the smaller initial download and is the recommended starting point for
this text/list-heavy application. For maximum visual fidelity and consistent
graphics rendering:

```powershell
flutter build web --release --web-renderer canvaskit --base-href /
```

The included helper accepts the same choice:

```powershell
.\tool\build_pwa.ps1 -Renderer html -BaseHref /
.\tool\build_pwa.ps1 -Renderer canvaskit -BaseHref /
```

If deploying under a subpath, use matching leading/trailing slashes, for example
`-BaseHref /indirimbo/`. Deploy the contents of `build/web`, not the directory
itself. Configure the host to rewrite unknown navigation routes to `index.html`,
serve `.wasm` as `application/wasm`, and avoid long-lived immutable caching for
`index.html`, `flutter_bootstrap.js`, and `pwa_service_worker.js`.

## 6. Verification

Serve the production output over HTTP rather than opening `index.html` directly:

```powershell
cd build\web
python -m http.server 8080
```

In Chrome DevTools, use Application > Manifest to check installability and
Application > Service Workers to enable Offline, then reload. Run Lighthouse in
an incognito profile for a clean PWA/performance audit.
