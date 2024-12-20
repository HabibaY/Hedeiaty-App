# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Gift Management Application

## Overview

The Gift Management Application is a Flutter-based solution designed for event and gift management. Users can create and manage events, pledge and manage gifts, and update their profiles seamlessly. The app supports offline functionality via local storage and real-time synchronization with Firestore, ensuring a smooth user experience.

---

## Features

- **User Management**:
  - Secure user registration and login.
  - Profile management with options to update personal details and profile images.
  - Notification preferences toggle.

- **Event Management**:
  - Create, edit, delete, and view events.
  - Group events by upcoming, current, and past categories.
  - Publish events to Firestore for sharing with others.

- **Gift Management**:
  - Create, edit, delete, and view gifts associated with events.
  - Real-time updates for gift pledges and status changes.
  - View friend-specific gift lists.

- **Pledge Management**:
  - Pledge and cancel gifts with real-time updates.
  - Restrict cancellations close to the event due date.

- **Notifications**:
  - Receive notifications for new pledges or pledge cancellations.

---

## Project Structure
gift-management-app/
├── android/                  # Android-specific files (e.g., configurations, Gradle settings)
├── ios/                      # iOS-specific files (e.g., configurations, Xcode settings)
├── lib/                      # Main application codebase
├── test/                     # Automated test files
├── pubspec.yaml              # Flutter dependencies and metadata
├── README.md                 # Project documentation
├── LICENSE                   # License information

- **lib/**:
  - `main.dart`: Entry point of the application.
  - `screens/`: Contains UI screens such as Home, Profile, Event List, Gift List, and Pledged Gifts.
  - `models/`: Includes models for User, Event, and Gift.
  - `controllers/`: Handles interactions between UI and data storage (e.g., `event_controller.dart`, `gift_controller.dart`).
  - `services/`: Contains helper classes for local storage and notifications (e.g., `local_storage_service.dart`, `notification_service.dart`).
- **lib/**:
├── main.dart                 
├── screens/                  
    ├── home_screen.dart      
    ├── sign_in_screen.dart  
    ├── sign_up_screen.dart   
    ├── profile_page_screen.dart
    ├── event_list_screen.dart 
    ├── event_details_screen.dart 
    ├── gift_list_screen.dart 
    ├── pledged_gifts_screen.dart 
    ├── create_edit_event_screen.dart 
    ├── create_edit_gift_screen.dart 
├── models/                  
   ├── user.dart            
   ├── event.dart            
   ├── gift.dart             
├── controllers/              
   ├── user_controller.dart 
   ├── event_controller.dart 
   ├── gift_controller.dart  
├── services/              
   ├── firebase_auth.dart   
   ├── local_storage_service.dart 
   ├── notification_service.dart
├── providers/               
   ├── user_provider.dart    
   ├── event_provider.dart  

test/
├── controllers/               # Unit tests for individual components
   ├── user_controller_test.dart  # Tests for UserController
   ├── event_controller_test.dart # Tests for EventController
   ├── gift_controller_test.dart  # Tests for GiftController
├── integration_tests/       
   ├── login_test.dart
   ├── scenario1.dart   
├── models/            
   ├── event_test.dart       
   ├── gift_test.dart 
   ├── user_test.dart   
├── DB/            
   ├── db_test.dart    


 


---

## Prerequisites

Ensure the following tools and dependencies are installed:

1. **Flutter**:
   - Install Flutter SDK: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. **Firebase**:
   - Configure a Firebase project:
     - Enable Firestore, Authentication, and Cloud Messaging.
   - Add the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to the respective folders.
3. **Database**:
   - SQLite is integrated into the project for local storage.

---

## Installation and Execution

### 1. Clone the Repository
### 2. Install Dependencies: flutter pub get
### 4. Firebase Configuration
Add the Firebase configuration files:
google-services.json to android/app/.
GoogleService-Info.plist to ios/Runner/.
### 4. flutter run --target-platform

Usage Instructions
Sign Up or Log In:

Create an account or log in with existing credentials.
Profile Management:

Update profile details and manage notification preferences.
Event Management:

Navigate to the Event List to create, edit, or delete events.
View detailed event information and associated gifts.
Gift Management:

Navigate to the Gift List to manage gifts for an event.
Pledge gifts for a friend's event or cancel pledges as required.
Notifications:

Receive notifications for pledged gifts and cancellations.
Tap notifications to navigate directly to relevant screens.



