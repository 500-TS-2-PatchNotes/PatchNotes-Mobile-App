import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patchnotes/mainscreen.dart';
import 'register.dart';

class LoginPageMobile extends StatefulWidget {
  LoginPageMobile({super.key});

  @override
  _LoginPageMobileState createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textSize = screenWidth * 0.05; // This will dynamically scale text size based on mobile screen size
    final double inputHeight = screenHeight * 0.065; // Also dynamically adjusts the input box's height

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                  .onDrag, // This will dismiss the keyboard when scrolling
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: screenHeight *
                                0.08), // This will dynamically adjust the spacing

                        // Login Title
                        Text(
                          'Login',
                          style: TextStyle(
                            color: const Color(0xFF967BB6),
                            fontSize: textSize * 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Sign in to your account',
                          style: TextStyle(
                            color: const Color(0xFF4A5568),
                            fontSize: textSize * 0.7,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Username Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
                          child: TextFormField(
                            controller: email,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFEDF2F7),
                              hintText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: inputHeight * 0.3,
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Password Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01),
                          child: TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFEDF2F7),
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: inputHeight * 0.3,
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: inputHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9696D9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              String message = '';
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                  );
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    print('success');
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => MainScreen(key: mainScreenKey),
                                      ),
                                    );
                                  });
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
                                    message = 'Invalid login credentials.';
                                  } else {
                                    message = e.code;
                                  }
                                  Fluttertoast.showToast(
                                    msg: message,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.SNACKBAR,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 14.0,
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Forgot Password
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: const Color(0xFF4A5568),
                              fontSize: textSize * 0.7,
                            ),
                          ),
                        ),

                        // Register New Account
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterPageMobile()));
                          },
                          child: Text(
                            'Register New Account',
                            style: TextStyle(
                              color: const Color(0xFF4A5568),
                              fontSize: textSize * 0.7,
                            ),
                          ),
                        ),

                        SizedBox(
                            height: screenHeight *
                                0.06), // Reduced bottom spacing for small screens
                      ],
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }
}
