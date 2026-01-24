# Drawo - Test Project

Drawo is a Flutter application developed for testing purposes. It implements a fully functional drawing canvas, secure user authentication, and cloud data synchronization using Firebase. The primary goal of this project is to demonstrate clean architecture, robust state management, and efficient resource handling in a modern Flutter environment.

## ⚠️ Flutter Version & Compatibility

> **Note:** This project was initially initialized using **Flutter 3.38.7**.
>
> During development, the active SDK version was switched to **Flutter 3.35.7** to ensure stability and compatibility with specific dev-tooling packages (specifically `device_preview`).
>
> *   **Current Environment**: Flutter 3.35.7
> *   **Compatibility**: The application has been fully tested and verified to function correctly on both 3.35.7 and 3.38.7.

## 🏗️ Architecture & Project Structure

The project follows a **Feature-First, Layered Architecture** using BLoC for state management. This separation of concerns ensures that the codebase is scalable, testable, and easy to maintain.

```text
lib/
├── core/                       # Core functionality shared across the app
│   ├── common/                 # Global utilities and Enums
│   ├── input/                  # Form models (Reactive Forms) for Auth
│   ├── languages/              # Localization logic & BloC
│   ├── routes/                 # AppRouter and navigation constants
│   ├── style/                  # Theme config, palettes, and text styles
│   └── service_locator.dart    # Dependency Injection setup (GetIt)
│
├── data/                       # Data Layer
│   ├── models/                 # Dart models (DrawingModel) with JSON/Firestore serialization
│   └── services/               # Firebase interactions (Auth, Firestore, Storage)
│
├── presentation/               # Presentation Layer (UI & State)
│   ├── auth/                   # Authentication feature (Login/Register screens + AuthBloc)
│   ├── drawing/                # Drawing feature (Canvas, Toolbar, Color Picker + DrawingBloc)
│   ├── gallery/                # Gallery feature (Grid view of artworks + GalleryBloc)
│   └── common/                 # Shared UI components (Glassmorphic containers, Buttons, etc.)
│
├── drawing_app.dart            # Root Widget (MultiBlocProvider setup)
└── main.dart                   # Entry point (Firebase init, DI setup)
```

## 🚀 Key Features Implementation

-   **Canvas Engine**: Custom `CustomPainter` implementation for performant, real-time drawing.
-   **State Management**: `flutter_bloc` is used for managing global app state (Auth, Language) and feature-specific state (Drawing events, Gallery fetching).
-   **Dependency Injection**: `get_it` is used to decouple services from UI components.
-   **Forms & Validation**: `reactive_forms` handles complex form validation for Login and Registration.
-   **Localization**: Built-in support for dynamic language switching (English/Russian) using `flutter_localizations`.
-   **Cloud Sync**: Real-time updates and storage using `cloud_firestore` and `firebase_storage`.
-   **Local Capability**: Usage of `gal` for saving images to the device gallery and `shared_preferences` for local settings.

## 🛠️ Technical Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter (Dart) |
| **State Management** | BLoC / Cubit |
| **Backend** | Firebase Auth, Firestore, Storage |
| **DI** | GetIt |
| **Input** | Reactive Forms |
| **Persistence** | Shared Preferences, Gal (Gallery) |
| **UI/UX** | Google Fonts, Glassmorphism Design |

## 🏁 Getting Started

### Prerequisites

-   Flutter SDK (3.35.7 recommended)
-   CocoaPods (for iOS)
-   Firebase Configuration (`google-services.json` / `GoogleService-Info.plist`)

### Installation Steps

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/ArshakHakobyan/drawo_app.git
    cd drawo_app
    ```

2.  **Install dependencies**:
    ```bash
    fvm flutter pub get
    ```

3.  **Run the application**:
    ```bash
    fvm flutter run
    ```

## ⚙️ iOS Build Optimization

To significantly reduce iOS build times, this project utilizes the **precompiled Firestore iOS SDK**. This prevents the compiler from building the massive Firestore C++ library from source.

If you clean the project or clone it for the first time, ensure you run:

```bash
cd ios
pod install
```

---
*Project maintained for testing and architectural demonstration.*

