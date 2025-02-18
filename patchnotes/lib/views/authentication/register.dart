import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterPageMobile extends StatefulWidget {
  const RegisterPageMobile({super.key});

  @override
  _RegisterPageMobileState createState() => _RegisterPageMobileState();
}

class _RegisterPageMobileState extends State<RegisterPageMobile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isSubmitting = false; // Tracks if form is being submitted

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      bool success = await authViewModel.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        firstNameController.text.trim(),
        lastNameController.text.trim(),
      );

      if (success) {
        _showToast("Registration successful! Redirecting to login...", Colors.green);

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/login");
          }
        });
      } else {
        _showToast(authViewModel.errorMessage ?? "Registration failed", Colors.red);
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textSize = screenWidth * 0.05;
    final double inputHeight = screenHeight * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08),
                Text(
                  'Register',
                  style: TextStyle(
                    color: const Color(0xFF967BB6),
                    fontSize: textSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // First Name
                _buildTextField(firstNameController, "First Name", false, screenWidth, inputHeight),
                // Last Name
                _buildTextField(lastNameController, "Last Name", false, screenWidth, inputHeight),
                // Email
                _buildTextField(emailController, "Email (Username)", false, screenWidth, inputHeight),
                // Password
                _buildTextField(passwordController, "Password", true, screenWidth, inputHeight),
                SizedBox(height: screenHeight * 0.02),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: inputHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9696D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting || authViewModel.isLoading ? null : () => _registerUser(context),
                    child: _isSubmitting || authViewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: textSize,
                            ),
                          ),
                  ),
                ),

                // Redirects to the login page
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(fontSize: textSize * 0.7),
                  ),
                ),
              ],
            ),
          ),
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
          if (hintText == "Email (Username)" &&
              !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
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

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
