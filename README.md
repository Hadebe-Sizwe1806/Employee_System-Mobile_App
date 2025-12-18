## 🚀 Employee Verification System
Flutter • Firebase • Provider

A cross-platform Flutter application designed to manage employee profiles and verification requests.
This project demonstrates modern Flutter development, secure Firebase integration, and clean architectural practices, making it suitable for both academic assessment and professional portfolios.

## 📌 Project Overview

The Employee Verification System allows employees to securely authenticate, manage their profiles, and submit required documents for verification requests.
Administrators can review and manage verification submissions through a structured and secure workflow. The application integrates Firebase Authentication and Cloud Firestore while following industry-standard security practices to ensure sensitive configuration and data are protected

## ✨ Key Features

* 🔐 Secure user authentication (Firebase Authentication)
* 👤 Employee profile creation, editing, and image upload
* 📄 Upload and submit verification documents
* ✅ Employee verification request management
* 🔄 Real-time data handling with Cloud Firestore
* 📱 Cross-platform support (Android, Web, Desktop)
* 🧼 Clean MVVM-style architecture
* 🔒 No sensitive credentials committed to GitHub

## 🛠️ Technology Stack
| Layer              | Technologies                                   |
|--------------------|-----------------------------------------------|
| Frontend           | Flutter, Dart                                 |
| State Management   | Provider                                      |
| Backend            | Firebase Authentication, Cloud Firestore      |
| Tooling            | FlutterFire CLI, Git                          |
| Platforms          | Android, Web, Desktop                         |


## 🔐 Firebase Configuration (Secure Setup)

This repository **does not include real Firebase credentials**.  
Sensitive configuration is excluded using `.gitignore`.

### ▶️ Local Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hadebe-Sizwe1806/Employee_System-Mobile_App.git
   cd Employee_System-Mobile_App
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



