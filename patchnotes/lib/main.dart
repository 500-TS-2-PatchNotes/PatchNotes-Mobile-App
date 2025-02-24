import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/providers/settings_provider.dart';
import 'package:patchnotes/views/authentication/login.dart';
import 'package:patchnotes/views/authentication/register.dart';
import 'package:patchnotes/views/mainscreen.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'utils/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final navigatorKey = ref.read(navigatorKeyProvider);
    final settingsState = ref.watch(settingsProvider); 

    return MaterialApp(
      title: 'Patch Notes',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: _lightTheme(), 
      darkTheme: _darkTheme(), 
      themeMode: settingsState.darkMode ? ThemeMode.dark : ThemeMode.light, 
      home: authState.firebaseUser == null
          ? const LoginPageMobile()
          : const MainScreen(), 
      routes: {
        "/login": (context) => const LoginPageMobile(),
        "/register": (context) => const RegisterPageMobile(),
        "/home": (context) => const MainScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginPageMobile(),
      ),
    );
  }

    ThemeData _lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF5B9BD5), // Light Blue
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white, // Ensure light card background
    iconTheme: const IconThemeData(color: Color(0xFF5B9BD5)), // Blue icons
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)), // Dark Text
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF2D3142)),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF2D3142)),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0xFF2D3142)),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Color(0xFF2D3142)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5B9BD5),
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B9BD5), 
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

ThemeData _darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey[900],
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    iconTheme: const IconThemeData(color: Colors.blueGrey),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white70),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white60),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}



}
