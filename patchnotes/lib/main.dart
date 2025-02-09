import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'login.dart';

//This is where the application is running from.
//The LoginPage is the first page the user sees when they open the app.


//Image Storage
final storage = FirebaseStorage
    .instance; //- Firebase Storage that is used to store wound images

//Database
FirebaseFirestore firestore =
    FirebaseFirestore.instance; //- Firestore stores information

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patch Notes',
      home: LoginPageMobile(),
    );
  }
}