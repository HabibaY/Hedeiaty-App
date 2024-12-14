import 'package:flutter/material.dart';
import '../storage/firebase_auth.dart'; // FirebaseAuthService for authentication
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../controllers/user_controller.dart'; // UserController for database operations

class ContinueSignUpScreen extends StatefulWidget {
  const ContinueSignUpScreen({super.key});

  @override
  State<ContinueSignUpScreen> createState() => _ContinueSignUpScreenState();
}

class _ContinueSignUpScreenState extends State<ContinueSignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserController _userController =
      UserController(); // Added UserController
  String? selectedImage;
  bool allowNotifications = true;
  String? errorMessage;

  // Select profile image from the "profile" folder in assets
  void _selectImage() {
    // Ensure the keyboard is dismissed
    FocusScope.of(context).unfocus();

    // List of available images
    final List<String> imagePaths = [
      'assets/profile/P1.PNG',
      'assets/profile/P2.PNG',
      'assets/profile/P3.png',
      'assets/profile/P4.png',
      'assets/profile/P5.png',
      'assets/profile/P6.png',
      'assets/profile/P7.png',
      'assets/profile/P8.png',
      'assets/profile/P9.PNG',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Choose a Photo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown, // Match the style in the provided image
            ),
          ),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: imagePaths.map((imagePath) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = imagePath;
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(imagePath),
                    backgroundColor: Colors.grey[200], // For better contrast
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Sign up and save user data using UserController
  Future<void> signUp(Map<String, String> args) async {
    try {
      final String username = args['username']!;
      final String email = args['email']!;
      final String phoneNumber = args['phoneNumber']!;
      final String password = args['password']!;

      if (selectedImage == null) {
        setState(() {
          errorMessage = "Please select a profile image.";
        });
        return;
      }

      // Firebase Authentication Sign-Up
      final user = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Hash the password
        final hashedPassword = _userController.hashPassword(password);
        // Reset and reinitialize the local database
        // await _userController
        //     .resetDatabaseAndReinitialize(); // Use the new method

        // // Save user locally using UserController
        // await _userController.addUser(
        //   user.uid,
        //   username,
        //   email,
        //   phoneNumber,
        //   allowNotifications,
        //   password,
        //   selectedImage!,
        // );

        // Store user information in Firestore using UserController
        await _userController.addUserToFirestore(
          uid: user.uid,
          name: username,
          email: email,
          phoneNumber: phoneNumber,
          notificationsEnabled: allowNotifications,
          password: hashedPassword,
          profileImagePath: selectedImage!,
        );

        // Save userId in UserProvider
        Provider.of<UserProvider>(context, listen: false).setUserId(user.uid);

        // Show success message
        _showSnackbar("Sign-up successful!");

        // Navigate to the loading screen
        Navigator.pushReplacementNamed(context, '/loading');
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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      body: Stack(
        children: [
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/app.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 24,
            right: 24,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Continue Signup',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                          ),
                          child: const Text(
                            'Select Profile Image',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Image.asset(
                              selectedImage!,
                              height: 100,
                              width: 100,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Allow Notifications for Gift Pledges',
                                style: TextStyle(fontSize: 14),
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
                        ElevatedButton(
                          onPressed: () => signUp(args),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
