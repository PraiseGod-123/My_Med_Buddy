# my_medbuddy

A Flutter-based personal health and medication management application that helps users track theri medications, appointment, health logs, and prescriptions with personalised features for offline and onine use.

## Getting Started

This project is a comprehensive Flutter application designed to demonstrate multi-screen navigation, state management, asynchronous programming, and API integration while solving health management challenges.

Key Features:

User Onboarding & Personalization:

- Form-based user registration capturing name, age, medical conditions, and medication preferences
- SharedPreferences integration for persistent user data storage

Multi-Screen Navigation Architecture:

- Home Dashboard with quick access to all features
- Medication Schedule management with reminder system
- Health Logs tracking for daily health metrics
- Appointments calendar and management
- User Profile and settings management
- Implements both named routes and Navigator.push for optimal navigation flow

Advanced UI Design & Responsive Layouts:

- Responsive dashboard layout utilizing Column, Row, Cards, ListView, GridView, and Stack widgets
- Real-time medication status display (Next Medication, Missed Doses, Weekly Appointments)
- Modern Material Design 3 implementation with custom color schemes
- Loading states and error handling with custom UI components

Comprehensive State Management:

- setState: Handles temporary form states, toggles, and local UI interactions
- Provider: Manages app-wide shared state including user authentication, health logs, and medication data
- Riverpod: Powers advanced features like health history filtering, appointment editing, and complex data operations
- Reactive programming patterns for real-time UI updates

Asynchronous Programming & API Integration:

- Real-time health tips and medication data fetching from public health APIs
- Loading spinner implementation during data fetch operations
- Comprehensive error handling with user-friendly error messages
- Network state management and offline data persistence

Advanced Features:
Notification System

- Flutter local notifications integration for medication reminders
- Smart notification scheduling based on user preferences
- Multiple notification channels for different reminder types

Project Structure:

lib/
├── main.dart # Application entry point
├── screens/ # Organized screen components
│ ├── home/ # Home dashboard
│ ├── medication/ # Medication management screens
│ ├── health_logs/ # Health logging interface
│ ├── appointments/ # Appointment management
│ └── profile/ # User profile and settings
├── widgets/ # Reusable custom widgets
│ ├── common/ # Common UI components
│ └── specialized/ # Feature-specific widgets
├── providers/ # State management
│ ├── user_provider.dart # User state management
│ ├── medication_provider.dart
│ └── health_logs_provider.dart
├── services/ # External integrations
│ ├── api_service.dart # HTTP API calls
│ ├── notification_service.dart
│ └── storage_service.dart # SharedPreferences helper
├── models/ # Data models
├── core/ # Core utilities and constants
└── generated/ # Generated asset references

Dependencies:
dependencies:
flutter: sdk
provider: ^6.1.1 # Basic state management
flutter_riverpod: ^2.4.9 # Advanced state management
shared_preferences: ^2.2.2 # Local data persistence
http: ^1.1.2 # API communication
intl: ^0.19.0 # Internationalization
flutter_local_notifications: ^16.3.2 # Local notifications
sqflite: ^2.3.0 # Local database
path: ^1.8.3 # File path utilities
pdf: ^3.10.7 # PDF generation

Usage Guide:

- First Launch: Complete the onboarding process by providing your health information
- Dashboard: Access all features from the main dashboard
- Medications: Add medications with custom schedules and receive reminders
- Health Logs: Track daily health metrics, symptoms, and observations
- Appointments: Schedule and manage medical appointments
- Settings: Customize notifications, themes, and data preferences
# My_Med_Buddy
# decentrallized.app
# My_MedBuddy
