import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:patchnotes/bluetooth/manager.dart';
import 'package:patchnotes/services/auth_service.dart';
import 'package:patchnotes/services/firestore_service.dart';
import 'package:patchnotes/viewmodels/auth_viewmodel.dart';
import 'package:patchnotes/viewmodels/dashboard_viewmodel.dart';
import 'package:patchnotes/viewmodels/notifications_viewmodel.dart';
import 'package:patchnotes/viewmodels/profile_viewmodel.dart';
import 'package:patchnotes/viewmodels/settings_viewmodel.dart';
import 'package:patchnotes/views/authentication/login.dart';
import 'package:patchnotes/views/authentication/register.dart';
import 'package:patchnotes/views/mainscreen.dart';
import 'package:provider/provider.dart';
import 'utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Caches the data on the device for faster data retrieval
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BacterialGrowthViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(_authService, _firestoreService)..listenToAuthChanges()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => BluetoothManager()),
      ],
      child: MaterialApp(
        title: 'Patch Notes',
        debugShowCheckedModeBanner: false,
        initialRoute: "/login",
        routes: {
          "/login": (context) => LoginPageMobile(),
          "/register": (context) => RegisterPageMobile(),
          "/home": (context) =>
              MainScreen(key: mainScreenKey), 
        },
      ),
    );
  }
}
