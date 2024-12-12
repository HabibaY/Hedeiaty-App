import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/firebase_auth.dart';
import '../providers/user_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  String? errorMessage;

  Future<void> signIn() async {
    try {
      if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+")
          .hasMatch(emailController.text)) {
        setState(() {
          errorMessage = "Invalid email format.";
        });
        return;
      }

      if (passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "Password cannot be empty.";
        });
        return;
      }

      final user = await _authService.signInWithEmailPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUserId(user.uid);
        Navigator.pushReplacementNamed(context, '/loading');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top image with fading effect and rounded corners
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/app.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Form Container
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33, // Adjust position
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Set background to white
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email TextField
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign-In Button
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 15),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // "Don't have an account?" link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.pinkAccent, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
