import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:patchnotes/providers/navigation.dart';
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

    return MaterialApp(
      title: 'Patch Notes',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, 
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
}
