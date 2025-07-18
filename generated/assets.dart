// lib/generated/assets.dart
// This file is generated to provide easy access to asset paths
// Update this file when adding new assets to the project

class Assets {
  // Private constructor to prevent instantiation
  Assets._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _fontsPath = 'assets/fonts';

  // Images
  static const String logo = '$_imagesPath/logo.png';
  static const String medicationIcon = '$_imagesPath/medication_icon.png';
  static const String healthLogIcon = '$_imagesPath/health_log_icon.png';
  static const String appointmentIcon = '$_imagesPath/appointment_icon.png';
  static const String onboardingWelcome = '$_imagesPath/onboarding_welcome.png';
  static const String onboardingMedication =
      '$_imagesPath/onboarding_medication.png';
  static const String onboardingTracking =
      '$_imagesPath/onboarding_tracking.png';
  static const String emptyStateIllustration = '$_imagesPath/empty_state.png';
  static const String errorIllustration = '$_imagesPath/error_illustration.png';
  static const String successIllustration =
      '$_imagesPath/success_illustration.png';

  // Icons
  static const String appIcon = '$_iconsPath/app_icon.png';
  static const String splashIcon = '$_iconsPath/splash_icon.png';
  static const String notificationIcon = '$_iconsPath/notification_icon.png';

  // Medication type icons
  static const String pillIcon = '$_iconsPath/pill_icon.png';
  static const String tabletIcon = '$_iconsPath/tablet_icon.png';
  static const String syrupIcon = '$_iconsPath/syrup_icon.png';
  static const String injectionIcon = '$_iconsPath/injection_icon.png';
  static const String dropIcon = '$_iconsPath/drop_icon.png';

  // Health log type icons
  static const String vitalsIcon = '$_iconsPath/vitals_icon.png';
  static const String symptomsIcon = '$_iconsPath/symptoms_icon.png';
  static const String moodIcon = '$_iconsPath/mood_icon.png';
  static const String exerciseIcon = '$_iconsPath/exercise_icon.png';
  static const String sleepIcon = '$_iconsPath/sleep_icon.png';
  static const String generalIcon = '$_iconsPath/general_icon.png';

  // Appointment type icons
  static const String doctorIcon = '$_iconsPath/doctor_icon.png';
  static const String dentistIcon = '$_iconsPath/dentist_icon.png';
  static const String specialistIcon = '$_iconsPath/specialist_icon.png';
  static const String checkupIcon = '$_iconsPath/checkup_icon.png';

  // Mood icons
  static const String excellentMoodIcon = '$_iconsPath/excellent_mood.png';
  static const String goodMoodIcon = '$_iconsPath/good_mood.png';
  static const String fairMoodIcon = '$_iconsPath/fair_mood.png';
  static const String poorMoodIcon = '$_iconsPath/poor_mood.png';
  static const String terribleMoodIcon = '$_iconsPath/terrible_mood.png';

  // Fonts
  static const String robotoFont = '$_fontsPath/Roboto';
  static const String robotoSlabFont = '$_fontsPath/RobotoSlab';

  // Lottie animations (if using Lottie)
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String medicationAnimation = 'assets/animations/medication.json';
  static const String healthAnimation = 'assets/animations/health.json';

  // All assets list for validation
  static const List<String> allAssets = [
    logo,
    medicationIcon,
    healthLogIcon,
    appointmentIcon,
    onboardingWelcome,
    onboardingMedication,
    onboardingTracking,
    emptyStateIllustration,
    errorIllustration,
    successIllustration,
    appIcon,
    splashIcon,
    notificationIcon,
    pillIcon,
    tabletIcon,
    syrupIcon,
    injectionIcon,
    dropIcon,
    vitalsIcon,
    symptomsIcon,
    moodIcon,
    exerciseIcon,
    sleepIcon,
    generalIcon,
    doctorIcon,
    dentistIcon,
    specialistIcon,
    checkupIcon,
    excellentMoodIcon,
    goodMoodIcon,
    fairMoodIcon,
    poorMoodIcon,
    terribleMoodIcon,
    loadingAnimation,
    successAnimation,
    errorAnimation,
    medicationAnimation,
    healthAnimation,
  ];

  // Helper methods
  static String getMedicationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
        return pillIcon;
      case 'tablet':
        return tabletIcon;
      case 'syrup':
        return syrupIcon;
      case 'injection':
        return injectionIcon;
      case 'drop':
        return dropIcon;
      default:
        return pillIcon;
    }
  }

  static String getHealthLogTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vitals':
        return vitalsIcon;
      case 'symptoms':
        return symptomsIcon;
      case 'mood':
        return moodIcon;
      case 'exercise':
        return exerciseIcon;
      case 'sleep':
        return sleepIcon;
      case 'general':
        return generalIcon;
      default:
        return generalIcon;
    }
  }

  static String getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'excellent':
        return excellentMoodIcon;
      case 'good':
        return goodMoodIcon;
      case 'fair':
        return fairMoodIcon;
      case 'poor':
        return poorMoodIcon;
      case 'terrible':
        return terribleMoodIcon;
      default:
        return fairMoodIcon;
    }
  }

  static String getAppointmentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'doctor':
        return doctorIcon;
      case 'dentist':
        return dentistIcon;
      case 'specialist':
        return specialistIcon;
      case 'checkup':
        return checkupIcon;
      default:
        return doctorIcon;
    }
  }

  // Validation method to check if asset exists
  static bool isValidAsset(String path) {
    return allAssets.contains(path);
  }
}

// Asset categories for organization
class AssetCategories {
  static const List<String> images = [
    Assets.logo,
    Assets.medicationIcon,
    Assets.healthLogIcon,
    Assets.appointmentIcon,
    Assets.onboardingWelcome,
    Assets.onboardingMedication,
    Assets.onboardingTracking,
    Assets.emptyStateIllustration,
    Assets.errorIllustration,
    Assets.successIllustration,
  ];

  static const List<String> icons = [
    Assets.appIcon,
    Assets.splashIcon,
    Assets.notificationIcon,
    Assets.pillIcon,
    Assets.tabletIcon,
    Assets.syrupIcon,
    Assets.injectionIcon,
    Assets.dropIcon,
  ];

  static const List<String> healthLogIcons = [
    Assets.vitalsIcon,
    Assets.symptomsIcon,
    Assets.moodIcon,
    Assets.exerciseIcon,
    Assets.sleepIcon,
    Assets.generalIcon,
  ];

  static const List<String> appointmentIcons = [
    Assets.doctorIcon,
    Assets.dentistIcon,
    Assets.specialistIcon,
    Assets.checkupIcon,
  ];

  static const List<String> moodIcons = [
    Assets.excellentMoodIcon,
    Assets.goodMoodIcon,
    Assets.fairMoodIcon,
    Assets.poorMoodIcon,
    Assets.terribleMoodIcon,
  ];

  static const List<String> animations = [
    Assets.loadingAnimation,
    Assets.successAnimation,
    Assets.errorAnimation,
    Assets.medicationAnimation,
    Assets.healthAnimation,
  ];
}
