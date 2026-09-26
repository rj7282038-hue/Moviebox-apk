# 🎬 MovieBox Mobile

> **Cross-Platform Mobile Application inspired by [MovieBox-TUI](https://github.com/mesamirh/MovieBox-TUI)**
> Find, stream, and download Movies, TV Series, Anime, and Live TV (IPTV) with hardware-accelerated playback and multi-provider stream resolution.

---

## 📱 Features

- **On Demand Streaming**: Stream movies, TV series, and anime with concurrent multi-provider and Stremio addon resolution.
- **Cinemeta Core Engine**: Rich metadata, posters, backdrops, cast, genres, seasons, and episodes without requiring any API keys.
- **Concurrent Stream Resolvers**: Queries enabled addons (Torrentio, CyberFlix, VidSrc Direct) simultaneously and sorts by resolution (`4K UHD`, `1080p FHD`, `720p HD`).
- **Live TV & IPTV**: Built-in M3U/M3U8 parser supporting custom playlist URLs, categories (Sports, News, Movies), and instant HLS live streaming.
- **In-App Video Player & Resume**: Auto-saves playback position every 5 seconds so you can resume movies exactly where you left off.
- **Multi-Segment Downloader**: Download individual episodes or movies in the background with progress tracking.
- **Stremio Addon Manager (Ctrl+P)**: Enable, disable, or install any community Stremio addon via manifest URL.
- **Private & Telemetry-Free**: Zero trackers, ads, or data collection.

---

## 📂 Project Structure

```
moviebox_mobile/
├── lib/
│   ├── main.dart                      # App entrypoint & provider setup
│   ├── models/
│   │   ├── media_item.dart            # Movie, TV series & episode models
│   │   ├── stream_source.dart         # Stream resolutions & audio/size specs
│   │   ├── iptv_channel.dart          # Live TV channel model
│   │   └── stremio_addon.dart         # Stremio Addon definition
│   ├── services/
│   │   ├── cinemeta_service.dart      # Cinemeta catalog, search & details
│   │   ├── stremio_service.dart       # Multi-addon concurrent stream resolver
│   │   ├── iptv_service.dart          # M3U playlist parser & curated HLS streams
│   │   ├── storage_service.dart       # Persistent history, favorites & settings
│   │   └── download_service.dart      # Background downloader engine
│   ├── widgets/
│   │   ├── media_card.dart            # Poster card with ratings & tags
│   │   ├── hero_banner.dart           # Home featured movie hero banner
│   │   └── stream_selector_modal.dart # Multi-resolution stream chooser bottom sheet
│   ├── screens/
│   │   ├── main_navigation_screen.dart# Bottom navigation controller
│   │   ├── home_screen.dart           # Trending movies, series & continue watching
│   │   ├── details_screen.dart        # Media details, seasons & episode picker
│   │   ├── player_screen.dart         # Custom video player with gestures & resume
│   │   ├── livetv_screen.dart         # IPTV channels & live player
│   │   ├── search_screen.dart         # Instant debounced search
│   │   ├── addons_screen.dart         # Stremio Addon manager
│   │   ├── library_screen.dart        # Watch history, watchlist & downloads
│   │   └── settings_screen.dart       # Stream quality & external player config
│   └── theme/
│       └── app_theme.dart             # Dark OLED theme with cyan accents
├── android/                           # Native Android configuration & Manifest
├── web_preview/
│   └── index.html                     # Instant interactive mobile web preview
└── pubspec.yaml                       # Dependencies & Flutter configuration
```

---

## 🚀 How to Run & Build

### 1. Instant Interactive Mobile Preview (Zero Install Required)
A complete interactive mobile prototype is included in `web_preview/index.html`.
You can open it right away in any browser (Chrome, Edge, Safari):
1. Navigate to: `C:\Users\Dell\.gemini\antigravity\scratch\moviebox_mobile\web_preview`
2. Double-click **`index.html`** or drag it into your web browser.
3. You can browse trending movies, search, resolve stream links, and stream live IPTV channels!

---

### 2. Building the Native Android APK

To build the native Android `.apk` file for your phone:

1. **Install Flutter SDK** (if not already installed) from [flutter.dev](https://flutter.dev).
2. Open PowerShell or Command Prompt in the project directory:
   ```bash
   cd C:\Users\Dell\.gemini\antigravity\scratch\moviebox_mobile
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Build the release APK:
   ```bash
   flutter build apk --release
   ```
5. Your compiled APK will be located at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```
6. Transfer this APK to your Android phone via USB, WhatsApp, or Google Drive and tap **Install**!

---

### 3. Running Directly on a Connected Android Phone

If you have USB debugging enabled on your Android device:
```bash
flutter run --release
```
