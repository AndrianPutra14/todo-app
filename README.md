# Todo App — Flutter + Go Backend

A clean, modern Todo application built with Flutter (Dart) for mobile frontend and Go (Golang) for REST API backend.

## Architecture

```
todo-app/
├── backend/                # Go REST API
│   ├── main.go            # Server entry point
│   ├── go.mod             # Go module definition
│   ├── data/
│   │   ├── store.go       # Data layer (JSON file storage)
│   │   └── todos.json     # Data persistence file
│   └── handlers/
│       └── handler.go     # HTTP request handlers
└── frontend-flutter/      # Flutter mobile app
    ├── pubspec.yaml       # Flutter dependencies
    └── lib/
        ├── main.dart                  # App entry point
        ├── models/
        │   └── todo.dart              # Todo data model
        ├── screens/
        │   └── home_screen.dart       # Main todo list screen
        ├── utils/
        │   ├── api_service.dart       # HTTP client for Go API
        │   └── todo_provider.dart     # State management (Provider)
        └── widgets/
            └── todo_card.dart         # Todo list item widget
```

## Prerequisites

- **Go** 1.21+ — installed
- **Flutter** 3.0+ — requires macOS 14+ for desktop build, but works on macOS 12.0 for **iOS/Android mobile builds**
- macOS 12.0 compatible for mobile development (iOS Simulator / Android Emulator)

## Backend Setup (Go)

```bash
cd backend

# Download dependencies
go mod tidy

# Run server (default port 8080)
go run main.go

# Or with custom port
PORT=3000 go run main.go
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/todos` | List all todos |
| POST | `/api/todos` | Create a new todo (body: `{"title": "..."}`) |
| GET | `/api/todos/:id` | Get a single todo |
| PUT | `/api/todos/:id` | Update todo (body: `{"title": "...", "done": true}`) |
| DELETE | `/api/todos/:id` | Delete a todo |

## Frontend Setup (Flutter)

```bash
cd frontend-flutter

# Get dependencies
flutter pub get

# Run on connected device or simulator
flutter run

# For iOS Simulator
flutter run -d ios

# For Android Emulator
flutter run -d android
```

### Configure API URL

Edit `lib/utils/api_service.dart`:

- **iOS Simulator / Android Emulator**: `http://localhost:8080/api`
- **Real device**: Use your Mac's local IP, e.g., `http://192.168.1.x:8080/api`

Find your IP:
```bash
ipconfig getifaddr en0
```

## Quick Start

1. Terminal 1 — Start Go backend:
   ```bash
   cd backend && go run main.go
   ```

2. Terminal 2 — Run Flutter app:
   ```bash
   cd frontend-flutter && flutter pub get && flutter run
   ```

## Notes for macOS 12.0

- Flutter **web/desktop** builds require macOS 14.0+
- Flutter **mobile** builds (iOS/Android) work fine on macOS 12.0
- Use an iOS Simulator or Android Emulator to run the Flutter app
