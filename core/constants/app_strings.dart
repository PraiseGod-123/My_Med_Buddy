class AppStrings {
  // App Info
  static const String appName = 'MyMedBuddy';
  static const String appTagline = 'Your Personal Health Companion';

  // Onboarding
  static const String welcomeTitle = 'Welcome to MyMedBuddy';
  static const String welcomeDescription =
      'Your personal health companion for managing medications, appointments, and health logs all in one place.';
  static const String medicationTitle = 'Never Miss a Dose';
  static const String medicationDescription =
      'Set medication reminders and track your daily doses with smart notifications and progress tracking.';
  static const String trackingTitle = 'Track Your Health';
  static const String trackingDescription =
      'Log your daily health metrics, symptoms, and appointments to maintain a comprehensive health record.';

  // Navigation
  static const String home = 'Home';
  static const String medications = 'Medications';
  static const String healthLogs = 'Health Logs';
  static const String appointments = 'Appointments';
  static const String profile = 'Profile';

  // Actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String update = 'Update';
  static const String complete = 'Complete';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String getStarted = 'Get Started';
  static const String viewAll = 'View All';
  static const String tryAgain = 'Try Again';

  // Form Labels
  static const String name = 'Name';
  static const String fullName = 'Full Name';
  static const String age = 'Age';
  static const String email = 'Email Address';
  static const String phone = 'Phone Number';
  static const String emergencyContact = 'Emergency Contact';
  static const String medicalCondition = 'Medical Condition';
  static const String allergies = 'Allergies';
  static const String medicationName = 'Medication Name';
  static const String dosage = 'Dosage';
  static const String frequency = 'Frequency';
  static const String instructions = 'Instructions';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String notes = 'Notes';
  static const String title = 'Title';
  static const String description = 'Description';

  // Placeholders
  static const String enterYourName = 'Enter your full name';
  static const String enterYourAge = 'Enter your age';
  static const String enterYourEmail = 'Enter your email address';
  static const String enterYourPhone = 'Enter your phone number';
  static const String describeMedicalCondition =
      'Describe your primary medical condition';
  static const String listAllergies = 'List any allergies, separated by commas';
  static const String enterMedicationName = 'Enter medication name';
  static const String enterDosage = 'e.g., 500mg, 1 tablet';
  static const String enterInstructions = 'Take with food, before bed, etc.';
  static const String enterTitle = 'Enter log title';
  static const String describeWhatHappened = 'Describe what happened';
  static const String additionalNotes = 'Additional notes';

  // Messages
  static const String medicationAddedSuccess = 'Medication added successfully';
  static const String medicationUpdatedSuccess =
      'Medication updated successfully';
  static const String healthLogAddedSuccess = 'Health log added successfully';
  static const String healthLogUpdatedSuccess =
      'Health log updated successfully';
  static const String fillRequiredFields =
      'Please fill in all required fields correctly';
  static const String noMedicationsYet = 'No medications added yet';
  static const String noHealthLogsYet = 'No health logs yet';
  static const String noAppointmentsYet = 'No appointments scheduled';
  static const String allCaughtUp = 'All caught up!';
  static const String noMedicationsDue = 'No medications due right now';
  static const String startTrackingHealth =
      'Start tracking your health by adding your first log entry';
  static const String addFirstMedication =
      'Add your first medication to start tracking';

  // Health Log Types
  static const String vitals = 'Vitals';
  static const String symptoms = 'Symptoms';
  static const String mood = 'Mood';
  static const String exercise = 'Exercise';
  static const String sleep = 'Sleep';
  static const String general = 'General';

  // Frequencies
  static const String onceDaily = 'Once daily';
  static const String twiceDaily = 'Twice daily';
  static const String threeTimes = 'Three times daily';
  static const String fourTimes = 'Four times daily';
  static const String asNeeded = 'As needed';

  // Moods
  static const String excellent = 'Excellent';
  static const String good = 'Good';
  static const String fair = 'Fair';
  static const String poor = 'Poor';
  static const String terrible = 'Terrible';

  // Error Messages
  static const String nameRequired = 'Name is required';
  static const String ageRequired = 'Age is required';
  static const String emailRequired = 'Email is required';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidAge = 'Please enter a valid age (1-120)';
  static const String fieldRequired = 'This field is required';
  static const String somethingWentWrong = 'Something went wrong';
  static const String loadingFailed = 'Failed to load data';

  // Settings
  static const String settings = 'Settings';
  static const String preferences = 'Preferences';
  static const String medicationReminders = 'Medication Reminders';
  static const String notificationsEnabled = 'Enable Notifications';
  static const String dailyLogReminder = 'Daily Log Reminder';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String theme = 'Theme';
  static const String about = 'About';
  static const String version = 'Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // Time
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String lastWeek = 'Last Week';
  static const String thisMonth = 'This Month';
  static const String dueIn = 'Due in';
  static const String overdue = 'Overdue';
  static const String taken = 'Taken';
  static const String missed = 'Missed';
  static const String skipped = 'Skipped';
  static const String hour = 'hour';
  static const String hours = 'hours';
  static const String minute = 'minute';
  static const String minutes = 'minutes';
  static const String day = 'day';
  static const String days = 'days';
}

// lib/core/constants/app_routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String userDetails = '/user-details';
  static const String home = '/home';
  static const String medications = '/medications';
  static const String addMedication = '/add-medication';
  static const String editMedication = '/edit-medication';
  static const String medicationDetails = '/medication-details';
  static const String healthLogs = '/health-logs';
  static const String addHealthLog = '/add-health-log';
  static const String editHealthLog = '/edit-health-log';
  static const String healthLogDetails = '/health-log-details';
  static const String appointments = '/appointments';
  static const String addAppointment = '/add-appointment';
  static const String editAppointment = '/edit-appointment';
  static const String appointmentDetails = '/appointment-details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
}
