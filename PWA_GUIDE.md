# Indirimbo PWA

## Build and deploy

Use Flutter stable and Node.js, then run:

```powershell
.\tool\build_pwa.ps1 -BaseHref /Himbaza-Imana/
```

For a root deployment, use `-BaseHref /`. The helper runs Flutter with its
legacy service worker disabled, then `node tool/prepare_pwa.mjs`. The GitHub
Pages workflow runs these same steps. Deploy the entire `build/web` directory.
Do not skip the preparation step: it generates the resource list and build hash
in the custom worker. Serve through HTTPS (localhost is also supported).

### Cloudflare Workers Builds

The connected `himbaza-imana` Worker uses these settings:

```text
Build command:  npm run build:cloudflare
Deploy command: npm run deploy:cloudflare
Root directory: /
```

The build command installs Flutter stable when the runner does not provide it,
creates a root-hosted release, prepares and tests the offline cache, and then
Wrangler deploys only `build/web`. The `wrangler.jsonc` SPA fallback keeps deep
links working. Never deploy the source `web` directory because it contains
Flutter placeholders that are replaced only during `flutter build web`.

## Offline behavior

The worker precaches every production file except service workers and source
maps, including app code, all three song collections, bundled icon fonts, and
the local CanvasKit renderer. Installation completes only when all resources have
been saved. Cache names change when build contents change. Navigation and
resources come from the same cached build. Updates wait for existing app windows
to close before activating, preventing a mixture of old and new code.

The first visit needs internet and enough time for the offline download to
finish. Open the installed app online once before testing offline. iOS can evict
website storage, so downloading again may be necessary if its cache is cleared.
Avoid long-lived immutable HTTP caching for index.html, flutter_bootstrap.js,
and pwa_service_worker.js.

## Full-screen layout

The manifest requests fullscreen. iPhone uses Apple's standalone web-app meta
tag with a translucent status bar and viewport-fit=cover. iOS controls the
system status bar. The Flutter shell fills the available width and height;
screens retain their SafeArea protection around controls.

Existing iPhone installations may need to be removed and added again through
Safari > Share > Add to Home Screen to pick up the display metadata.

## Verification

```powershell
node --test test/pwa_service_worker_test.mjs
```

Serve a fresh production build, wait for the service worker to activate, then
switch the browser offline and reload the root and a nested route. Check all
song collections and open lyrics that have never been viewed online. Repeat on
an iPhone: launch from the Home Screen, close it, enable airplane mode, and
relaunch. Check portrait and landscape, including the notch and home indicator.

Implementation references:
- https://docs.flutter.dev/platform-integration/web/initialization
- https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html
