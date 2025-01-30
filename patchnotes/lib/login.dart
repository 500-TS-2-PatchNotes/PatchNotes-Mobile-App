import 'package:flutter/material.dart';
import 'main.dart';

class AuthPageMobile extends StatefulWidget {
  const AuthPageMobile({super.key});

  @override
  _AuthPageMobileState createState() => _AuthPageMobileState();
}

class _AuthPageMobileState extends State<AuthPageMobile> {
  bool _isLogin = true;

  void _togglePage() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLogin
        ? LoginPageMobile(togglePage: _togglePage)
        : RegisterPageMobile(togglePage: _togglePage);
  }
}

class LoginPageMobile extends StatelessWidget {
  final VoidCallback togglePage;
  const LoginPageMobile({super.key, required this.togglePage});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textSize = screenWidth * 0.05; // Dynamically scale font size
    final double inputHeight = screenHeight * 0.065; // Adjust input box height

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                  .onDrag, // Dismiss keyboard on scroll
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height:
                            screenHeight * 0.08), // Adjusted dynamic spacing

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
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: TextField(
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
                      ),
                    ),

                    // Password Field
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: TextField(
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainScreen()),
                          );
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
                      onPressed: togglePage,
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class RegisterPageMobile extends StatelessWidget {
  final VoidCallback togglePage;
  const RegisterPageMobile({super.key, required this.togglePage});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textSize = screenWidth * 0.05;
    final double inputHeight = screenHeight * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.08),
              Text('Register',
                  style: TextStyle(
                      color: Color(0xFF967BB6),
                      fontSize: textSize * 1.2,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: screenHeight * 0.04),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEDF2F7),
                  hintText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEDF2F7),
                  hintText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEDF2F7),
                  hintText: "Email (Username)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEDF2F7),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: inputHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9696D9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen()), // Navigate to MainScreen
                    );
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: togglePage,
                  child: Text('Already have an account? Login',
                      style: TextStyle(fontSize: textSize * 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
