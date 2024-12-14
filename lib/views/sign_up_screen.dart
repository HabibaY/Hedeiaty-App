import 'package:flutter/material.dart';
import '../storage/firebase_auth.dart'; // FirebaseAuthService for authentication
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../controllers/user_controller.dart'; // UserController for database operations

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserController _userController = UserController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedImage;
  bool allowNotifications = true;
  String? errorMessage;

  // Select profile image from the "profile" folder in assets
  void _selectImage() {
    FocusScope.of(context).unfocus(); // Dismiss the keyboard

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
              color: Colors.brown,
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
                    backgroundColor: Colors.grey[200],
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
  Future<void> signUp() async {
    try {
      final String username = usernameController.text.trim();
      final String email = emailController.text.trim();
      final String phoneNumber = phoneNumberController.text.trim();
      final String password = passwordController.text;

      if (username.isEmpty ||
          email.isEmpty ||
          phoneNumber.isEmpty ||
          password.isEmpty) {
        setState(() {
          errorMessage = "All fields must be filled.";
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          errorMessage = "Password must be at least 6 characters long.";
        });
        return;
      }

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
        print("User authenticated successfully with UID: ${user.uid}");

        final hashedPassword = _userController.hashPassword(password);

        // Save user to Firestore
        await _userController.addUserToFirestore(
          uid: user.uid,
          name: username,
          email: email,
          phoneNumber: phoneNumber,
          notificationsEnabled: allowNotifications,
          password: hashedPassword,
          profileImagePath: selectedImage!,
        );

        // Fetch user data from Firestore
        // Fetch user data from Firestore using UserController
        final fetchedUser =
            await _userController.fetchUserFromFirestore(user.uid);

        if (fetchedUser != null) {
          // Reset and initialize the local database
          await _userController.resetDatabaseAndReinitialize();

          // Save the fetched user data locally
          await _userController.addUser(
            fetchedUser.uid,
            fetchedUser.name,
            fetchedUser.email,
            fetchedUser.phoneNumber,
            fetchedUser.notificationsEnabled,
            fetchedUser.password,
            fetchedUser.profileImagePath,
          );

          print("User data successfully fetched and stored locally.");
        } else {
          setState(() {
            errorMessage = "Failed to fetch user data from Firestore.";
          });
        }

        // Update the user ID in the provider
        Provider.of<UserProvider>(context, listen: false).setUserId(user.uid);

        _showSnackbar("Sign-up successful!");
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/app.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
      ),
    );
  }
}
