import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../mainscreen.dart';

class LoginPageMobile extends StatelessWidget {
  LoginPageMobile({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textSize = screenWidth * 0.05;
    final double inputHeight = screenHeight * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.08),
                      Text('Login',
                          style: TextStyle(
                            color: const Color(0xFF967BB6),
                            fontSize: textSize * 1.2,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: screenHeight * 0.01),
                      Text('Sign in to your account',
                          style: TextStyle(
                            color: const Color(0xFF4A5568),
                            fontSize: textSize * 0.7,
                          )),
                      SizedBox(height: screenHeight * 0.04),

                      // Email Field
                      _buildTextField(emailController, "Email", false,
                          screenWidth, inputHeight),

                      // Password Field
                      _buildTextField(passwordController, "Password", true,
                          screenWidth, inputHeight),
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
                          onPressed: authViewModel.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool success = await authViewModel.login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                    mainScreenKey.currentState?.reset();
                                    if (success) {
                                      Navigator.pushReplacementNamed(
                                          context, "/home");
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              authViewModel.errorMessage ??
                                                  "Login failed"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: authViewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
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
                          Navigator.pushReplacementNamed(context, "/register");
                        },
                        child: Text(
                          'Register New Account',
                          style: TextStyle(
                            color: const Color(0xFF4A5568),
                            fontSize: textSize * 0.7,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      bool obscureText, double screenWidth, double inputHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: inputHeight * 0.1),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEDF2F7),
          hintText: hintText,
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
            return "Please enter your $hintText";
          }
          if (hintText == "Email" && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (hintText == "Password" && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}
