## 🔐 Firebase Configuration (Secure Setup)

This repository **does not include real Firebase credentials**.  
Sensitive configuration is excluded using `.gitignore`.

### ▶️ Local Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hadebe-Sizwe1806/Consultation_Booking_App.git
   cd Consultation_Booking_App
2. **Install dependencies**
      ```bash
    flutter pub get
3. **Create a Firebase project**<br>
   * Go to the Firebase Console<br>
   * Enable Authentication and Cloud Firestore
4. **Configure Firebase for Flutter**
    ```bash
   flutterfire configure
5. **Create local Firebase config**
   ```bash
   cp lib/firebase_options_example.dart lib/firebase_options.dart
6. **Run the application**
   ```bash
   flutter run



