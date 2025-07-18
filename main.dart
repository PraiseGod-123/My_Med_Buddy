// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/themes/theme_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/health_logs_provider.dart';
import 'providers/appointments_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MyMedBuddyApp());
}

class MyMedBuddyApp extends StatelessWidget {
  const MyMedBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // Add ThemeProvider
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => HealthLogsProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MyMedBuddy',
            debugShowCheckedModeBanner: false,

            // Use AppTheme class for consistent theming
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // Control theme mode based on ThemeProvider
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
