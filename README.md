# 💊 MediBesti

**MediBesti** is an intelligent medication management Flutter app that allows users to scan prescriptions, receive medicine reminders, track allergies, and connect with doctors — all from one place. Designed for simplicity, accessibility, and daily wellness.

![App Logo](lib/assets/onboarding/logo.png)

---

## 🚀 Features

- 📸 **Smart Prescription Reader**  
  Extracts medicine details from photos of handwritten or printed prescriptions using OCR.

- ⏰ **Personalized Reminders**  
  Automatically creates medicine schedules with daily notifications.

- ⚠️ **Allergy Detection Alerts**  
  Detects and warns you of medications that match your saved allergens.

- 🖼️ **Prescription Gallery**  
  Save, view, and manage uploaded prescriptions with delete and preview options.

- 🔐 **Secure Allergy Storage**  
  Your allergy data is securely stored using Flutter Secure Storage.

- 💬 **Real-Time Doctor Chat**  
  Talk to doctors through a built-in chat system powered by Firebase Firestore.

- 💡 **Daily Health Tips**  
  Get a new health tip every day for a healthier lifestyle.

- ⚙️ **Customizable Settings**  
  Manage allergy data, clear reminders, control notification preferences, and more.

## 🧱 Tech Stack

| Tech | Purpose |
|------|---------|
| **Flutter** | Cross-platform UI |
| **Firebase Firestore** | Real-time chat backend |
| **Google ML Kit** | OCR for prescription reading |
| **flutter_local_notifications** | Scheduling local medicine reminders |
| **flutter_secure_storage** | Encrypted allergy data storage |
| **shared_preferences** | Onboarding and reminder state |
| **flutter_chat_ui** | Beautiful chat UI |
| **image_picker** | Camera/gallery integration |

---

## 🛠️ Installation

### 🔧 Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / VS Code
- Firebase Project (for chat feature)

### ⚙️ Setup

1. **Clone the repo**
```bash
git clone https://github.com/NayanaBN/medibesti.git
cd medibesti
