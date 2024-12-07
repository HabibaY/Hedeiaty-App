import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8 encoding
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_storage_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool allowNotifications = true; // Default value for notifications toggle
  String? errorMessage;
  final LocalStorageService localStorageService = LocalStorageService();

  Future<void> signUp() async {
    try {
      // Validate input fields
      if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+")
          .hasMatch(emailController.text)) {
        setState(() {
          errorMessage = "Invalid email format.";
        });
        return;
      }

      if (passwordController.text.length < 6) {
        setState(() {
          errorMessage = "Password must be at least 6 characters long.";
        });
        return;
      }

      if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumberController.text) ||
          phoneNumberController.text.length != 11) {
        setState(() {
          errorMessage = "Invalid phone number. Must be 11 digits.";
        });
        return;
      }

      // Register the user in Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get Firebase UID
      final String firebaseUid = userCredential.user!.uid;

      // Delete the local database to reset it
      await localStorageService.deleteDatabaseFile();

      // Reinitialize the local database
      final db = await localStorageService.database;

      // Hash the password using SHA-256
      String hashedPassword =
          sha256.convert(utf8.encode(passwordController.text)).toString();

      // Insert user into the local database and fetch the local ID
      int localUserId = await localStorageService.insertUser({
        'name': usernameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'notificationsEnabled': allowNotifications ? 1 : 0,
        'password': hashedPassword,
      });

      // Store user in Firestore, including the local ID and Firebase UID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUid)
          .set({
        'name': usernameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'notificationsEnabled': allowNotifications,
        'localId': localUserId, // Store the local ID
        'password': hashedPassword,
      });

      // Show success message
      _showSnackbar("Sign-up successful!");

      // Navigate to the loading screen
      Navigator.pushReplacementNamed(context, '/loading');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = "Email is already in use.";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          errorMessage = "The password provided is too weak.";
        });
      } else {
        setState(() {
          errorMessage = "Authentication error: ${e.message}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred: $e";
      });
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top image with fading effect and rounded top corners
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
          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
          // Form and UI elements
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 24,
            right: 24,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compressed Form Container
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Compress the height
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username TextField
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
                        // Phone Number TextField
                        TextField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 16),
                        // Allow Notifications Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Allow Notifications for Gift Pledges',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch(
                              value: allowNotifications,
                              onChanged: (value) {
                                setState(() {
                                  allowNotifications = value;
                                });
                              },
                              activeColor: Colors.pinkAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Create Account Button
                        ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Already have an account link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Already have an account? Sign In',
                        style:
                            TextStyle(color: Colors.pinkAccent, fontSize: 14),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
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
