# Chinese Family Tree - Flutter Frontend

Mobile application for managing Chinese family trees (家谱).

## Quick Start

### Prerequisites

- Flutter SDK 3.0 or later
- Dart 3.0 or later
- Backend API running (see [backend/README.md](../backend/README.md))

### Installation

```bash
cd frontend

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

### Configuration

Update the API base URL in `lib/main.dart`:

```dart
Provider<ApiService>(
  create: (_) => ApiService(baseUrl: 'http://YOUR_SERVER_IP:8080'),
),
```

**For Android Emulator:** Use `http://10.0.2.2:8080`  
**For iOS Simulator:** Use `http://localhost:8080`  
**For Physical Device:** Use your computer's IP address

## Features

### 📱 Screens

1. **首页 (Home)** - Dashboard with stats and recent persons
2. **族人 (Persons)** - List view with filtering
3. **族谱 (Family Tree)** - Visual family tree by generation
4. **搜索 (Search)** - Search by name, generation, or family name

### ✨ Capabilities

- ✅ Add/Edit/Delete persons
- ✅ Chinese naming support (姓，名，字辈，字，号)
- ✅ Gender tracking (男/女)
- ✅ Birth/death dates with lunar calendar support
- ✅ Generation-based family tree visualization
- ✅ Search and filtering
- ✅ Material Design 3 UI
- ✅ Dark mode support

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── person.dart              # Person data model
├── screens/
│   ├── home_screen.dart         # Dashboard
│   ├── person_list_screen.dart  # Person list
│   ├── person_detail_screen.dart # Person details
│   ├── person_form_screen.dart  # Add/Edit form
│   ├── family_tree_screen.dart  # Tree visualization
│   └── search_screen.dart       # Search
├── services/
│   ├── api_service.dart         # REST API client
│   └── person_provider.dart     # State management
└── widgets/                     # Reusable components
```

## State Management

Uses **Provider** for state management:

```dart
// Access in any widget
final provider = context.read<PersonProvider>();
await provider.loadPersons();
await provider.createPerson(person);
```

## API Integration

The app connects to the Go backend via REST API:

| Frontend | Backend Endpoint |
|----------|-----------------|
| `loadPersons()` | `GET /api/persons` |
| `getPerson(id)` | `GET /api/persons/:id` |
| `createPerson(p)` | `POST /api/persons` |
| `updatePerson(p)` | `PUT /api/persons/:id` |
| `deletePerson(id)` | `DELETE /api/persons/:id` |
| `searchPersons(q)` | `GET /api/persons/search?q=` |

## Building

### Android

```bash
flutter build apk
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

### Web

```bash
flutter build web
```

## Development

### Run with debug mode

```bash
flutter run --debug
```

### Hot reload

Press `r` in terminal or save files in your editor.

### Format code

```bash
flutter format .
```

### Analyze

```bash
flutter analyze
```

## Screenshots

### Home Screen
- Family statistics (total, male, female, surnames)
- Recent persons list
- Quick add button

### Person List
- Filterable by surname and generation
- Swipe actions (edit, delete)
- Gender indicators

### Family Tree
- Grouped by generation (字辈)
- Interactive zoom/pan
- Visual heir markers (长子)

### Search
- Multiple search types
- Real-time results
- Filter chips

## Localization

Currently supports Chinese (zh) and English (en).

To add more languages, update `lib/l10n/` with ARB files.

## Next Steps

- [ ] Add marriage relationship UI
- [ ] Add parent-child relationship editor
- [ ] Photo upload for persons
- [ ] Export family tree as PDF
- [ ] Import from GEDCOM format
- [ ] Offline mode with local database
- [ ] Multi-language support

## Troubleshooting

### Connection refused

Make sure the backend is running:

```bash
cd ../backend
go run ./cmd/main.go
```

### No devices found

Connect a device or start an emulator:

```bash
flutter devices
flutter emulators --launch <emulator_id>
```

### Build fails

Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

---

**家谱传承，从指尖开始**  
*Preserving family heritage, one tap at a time*
