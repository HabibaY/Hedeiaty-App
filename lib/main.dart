import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart'; // Import UserProvider
import 'providers/event_provider.dart'; // Import EventProvider
import 'views/create_edit_event_screen.dart';
import 'views/create_edit_gift_screen.dart';
import 'views/event_list_screen.dart';
import 'views/friend_gift_list_screen.dart';
import 'views/gift_list_screen.dart';
import 'views/home_screen.dart';
import 'views/loading_screen.dart';
import 'views/sign_in_screen.dart';
import 'views/profile_page_screen.dart';
import 'views/pledged_gifts_screen.dart';
import 'views/sign_up_screen.dart';
import 'views/continue_signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => EventProvider()), // Add EventProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, EventProvider>(
      builder: (context, userProvider, eventProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            scaffoldBackgroundColor:
                Colors.purple[50], // Light purple background
          ),
          home: const WelcomeScreen(),
          //initialRoute: '/',
          routes: {
            '/welcome': (context) =>
                const WelcomeScreen(), // Welcome screen is the initial route
            '/home': (context) => const HomeScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/login': (context) => const SignInScreen(),
            '/register': (context) => const SignUpScreen(),
            '/continue_signup': (context) =>
                const ContinueSignUpScreen(), // Added this route
            '/profile': (context) => const ProfilePageScreen(),
            '/eventList': (context) => EventListScreen(
                  userId:
                      userProvider.userId ?? '', // Get userId from UserProvider
                ),
            '/createEvent': (context) => CreateEditEventScreen(
                  userId:
                      Provider.of<UserProvider>(context, listen: false).userId!,
                ),
            '/editEvent': (context) => CreateEditEventScreen(
                  eventId: Provider.of<EventProvider>(context, listen: false)
                      .eventId!,
                  userId:
                      Provider.of<UserProvider>(context, listen: false).userId!,
                ),
            '/giftList': (context) => GiftListScreen(
                  eventId: eventProvider.eventId ??
                      0, // Get eventId from EventProvider
                ),
            '/createGift': (context) => CreateEditGiftScreen(
                  eventId: eventProvider.eventId ??
                      0, // Get eventId from EventProvider
                ),
            '/editGift': (context) => CreateEditGiftScreen(
                  eventId: eventProvider.eventId ??
                      0, // Get eventId from EventProvider
                ),
            '/friendGiftList': (context) =>
                const FriendGiftListScreen(), // Unchanged route
            '/pledgedGifts': (context) =>
                const PledgedGiftsScreen(), // Unchanged route
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Background Image
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Translucent Overlay
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.3),
          ),
          // Welcome Header Text
          const Positioned(
            top: 80,
            left: 24,
            right: 24,
            child: Text(
              'Welcome to Hedeiaty app!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Centered Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'All the fun starts here! Want to feel the happy vibe? Create an account and you are all set to go!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Already have an account? Sign In here!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
