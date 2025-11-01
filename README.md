cat > README.md << 'EOF'
# Mini Mart App 🛒

A Flutter mobile application for Mini Mart management system - Final exam project Year 4 Semester 1.

## 📱 About

This is a comprehensive Mini Mart mobile application built with Flutter that connects to a Spring Boot API backend. The app provides features for product management, shopping cart, order processing, and payment integration with KHQR.

## 🚀 Features

- 🔐 User Authentication (Login/Register)
- 🛍️ Product Catalog with Categories
- 🛒 Shopping Cart Management
- 📦 Order Management
- 💳 Payment Integration (KHQR)
- 📍 Location & Maps Integration
- 📊 Sales Analytics
- 🔔 Push Notifications (Firebase)
- 📷 Barcode/QR Scanner
- 🖼️ Image Upload & Management

## 🛠️ Built With

- **Flutter** 3.35.5 (Dart 3.9.2)
- **State Management:** flutter_bloc
- **Network:** Dio
- **Local Storage:** shared_preferences, flutter_secure_storage
- **Maps:** google_maps_flutter, geolocator
- **Payment:** khqr_sdk, khqr_widget
- **Scanner:** mobile_scanner
- **Firebase:** firebase_core, firebase_messaging
- **UI Components:** fl_chart, carousel_slider, flutter_slidable

## 📋 Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / Xcode
- Java 17 (for Android)
- CocoaPods 1.16.2 (for iOS)

## 🔧 Installation

1. **Clone the repository**
```bash
   git clone https://github.com/nang22786/Mini-Mart-App.git
   cd Mini-Mart-App
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Configure environment variables**
   - Create a `.env` file in the project root
   - Add your API configurations (see `.env.example`)

4. **Configure Firebase**
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

5. **Run the app**
```bash
   flutter run
```

## 🔗 Backend API

This app connects to a Spring Boot REST API deployed on DPDC VPS.

- **Base URL:** `http://157.10.73.21`
- **API Documentation:** [Postman Collection]

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)

## 📦 Project Structure
```
mini_mart/
├── lib/
│   ├── bloc/          # State management (BLoC)
│   ├── models/        # Data models
│   ├── repositories/  # API repositories
│   ├── screens/       # UI screens
│   ├── widgets/       # Reusable widgets
│   └── main.dart      # App entry point
├── assets/
│   ├── fonts/         # Custom fonts
│   └── logo/          # App logos
├── android/           # Android configuration
├── ios/               # iOS configuration
└── pubspec.yaml       # Dependencies
```

## 🎨 App Screenshots

[Add screenshots here]

## 🔐 Environment Variables

Create a `.env` file with:
```env
API_BASE_URL=http://157.10.73.21
GOOGLE_MAPS_API_KEY=your_api_key_here
```

## 🧪 Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Build APK/IPA
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 👥 Team

- **Developer:** Samnang Yorn
- **Email:** samnangyorn1@gmail.com
- **University:** [Your University]
- **Year:** 4th Year, Semester 1

## 📄 License

This project is created for educational purposes as a final exam project.

## 🙏 Acknowledgments

- Spring Boot API Backend
- DPDC (Daun Penh Data Center) for hosting
- Flutter & Dart teams
- All package contributors

## 📞 Contact

For any questions or issues, please contact:
- Email: samnangyorn1@gmail.com
- Phone: +855 96 326 0924

---

**© 2025 Mini Mart App - Final Exam Project**
EOF
