# Indirimbo

Indirimbo is an offline Flutter songbook for Christian hymns and worship songs in Kinyarwanda. The app includes the Umugeni, Ugushimisha, and Agakiza collections and is published under the name **Himbaza Imana**.

## Features

- Browse songs using list, grid, compact-grid, or card layouts
- Search song titles and lyrics across all collections
- Read formatted verses and choruses
- Increase or decrease the lyrics font size
- Switch between persistent light and dark themes
- Select lyrics or copy a complete song to the clipboard
- Keep the screen awake while using the songbook
- Save songs as favorites on the device
- Open saved songs from the Favorites tab
- Move to the first, previous, next, or last song from a lyrics page
- Use the bundled song collections without an internet connection

## Song data

The song collections are bundled with the application:

- `assets/bride_songs.json`
- `assets/hymns_praise_songs.json`

Favorites are stored locally with `shared_preferences`. No account or remote database is required.

## Requirements

- Flutter 3.24 or later
- Dart 3.5 or later
- Android Studio and an Android SDK for Android development
- Visual Studio with Desktop development with C++ for Windows development
- Xcode for iOS or macOS development

## Run locally

Install dependencies:

```sh
flutter pub get
```

Check the available devices:

```sh
flutter devices
```

Start the app on a connected device or emulator:

```sh
flutter run
```

To select a specific device:

```sh
flutter run -d <device-id>
```

## Quality checks

```sh
flutter analyze
flutter test
```

## Build

Create an Android APK:

```sh
flutter build apk
```

Create a Windows release build:

```sh
flutter build windows
```

Release builds currently use the Android debug signing configuration. Configure a private release keystore before publishing the app.

## Project structure

```text
assets/          Bundled icons and song collections
lib/models/      Song and search data types
lib/page/        Home and lyrics pages
lib/providers/   Song, favorite, and theme state
lib/screens/     Reusable song collection views
lib/services/    Song search and preview logic
lib/widgets/     Shared interface components
```
