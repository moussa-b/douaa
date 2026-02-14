# Douaa

A Flutter mobile app for browsing and managing Islamic duas (supplications) in Arabic with French translations. Data is stored locally; you can ship a pre-filled SQLite database or start from an empty one.

**Aim:** Provide a simple, offline-first way to read duas by category, toggle favorites, show or hide references and translations, and optionally keep the screen on while reading. The app supports adding your own categories and duas.

---

## Dependencies

| Package | Purpose |
|--------|---------|
| **sqflite** | Local SQLite database (categories, sub-categories, douaa, favorites). |
| **flutter_riverpod** | State management (category/douaa lists, settings, view mode). |
| **shared_preferences** | Persist user settings (show reference, show translation, keep screen awake). |
| **wakelock_plus** | Keep the screen on when enabled in Settings. |
| **package_info_plus** | Display app version in Settings. |
| **cupertino_icons** | iOS-style icons. |

Dev: `flutter_test`, `flutter_lints`.

---

## Architecture

### Folder structure

```
lib/
├── main.dart              # Entry point, ProviderScope
├── app.dart               # MaterialApp, theme
├── database/
│   └── database_helper.dart   # SQLite init, copy from asset, CRUD
├── models/
│   ├── category.dart
│   ├── sub_category.dart
│   └── douaa.dart
├── providers/
│   ├── category_provider.dart    # Categories + favorite categories
│   ├── sub_category_provider.dart
│   ├── douaa_provider.dart
│   └── settings_provider.dart   # App settings + view mode (grid/list)
├── screens/
│   ├── app_shell.dart           # Bottom nav + IndexedStack
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   ├── settings_screen.dart
│   ├── category_detail_screen.dart
│   └── douaa_form_screen.dart
└── widgets/
    ├── category_card.dart
    ├── douaa_card.dart
    └── add_category_dialog.dart
```

### Data and UI flow

- **Data:** SQLite (`douaa.db`) is the single source of truth. On first run, the app copies `assets/douaa.db` into app storage if present; otherwise it creates an empty DB. All reads/writes go through `DatabaseHelper`.
- **State:** Riverpod providers wrap the DB and preferences: `categoryListProvider`, `douaaListProvider(categoryId)`, `favoriteCategoriesProvider`, `settingsProvider`, `viewModeProvider`. Screens are `ConsumerWidget`/`ConsumerStatefulWidget` and watch these providers.
- **Navigation:** One activity: bottom navigation (Home, Favorites, Settings) with `IndexedStack` to keep tab state. From Home or Favorites, tapping a category opens the category detail screen; from there you can add/edit a douaa. No routing library; `Navigator.push` with `MaterialPageRoute`.

### Database schema (expected in your `douaa.db`)

- **category** — `id`, `name`
- **sub_category** — `id`, `name`, `category_id`
- **douaa** — `id`, `category_id`, `sub_category_id`, `douaa_ar`, `douaa_fr`, `reference`, `tags`, `is_favorite`

See `specs/specs.md` for the full specification and `assets/README.txt` for how to bundle your pre-created database.

---

## Getting started

1. Clone the project, run `flutter pub get`.
2. (Optional) Place your pre-created `douaa.db` in `assets/douaa.db` so it is bundled and used on first launch.
3. Run with `flutter run` (or your target device).

For more on Flutter: [documentation](https://docs.flutter.dev/).
