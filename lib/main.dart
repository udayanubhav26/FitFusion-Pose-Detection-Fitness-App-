import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'package:ui/pages/IconPage.dart';
import 'package:ui/pages/Live.dart';
import 'package:ui/pages/home.dart';
import 'package:ui/pages/more.dart';
import 'package:ui/pages/settings.dart';
import 'package:ui/pages/search.dart';
// SignUp page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const SplashImagePage(),
    );
  }
}

// mainscreen with bottom navigation
class MainScreen extends StatefulWidget {
  final String userName;

  const MainScreen({super.key, required this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  String? userId;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId'); // load Firestore user ID
      profileImageUrl = prefs.getString('userProfileImage');
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
  Home(userName: widget.userName), // username for greeting
  const Search(),
  const PoseDetectionPage(),
  const MorePage(),
  if (userId != null)
    SettingsPage(userId: userId!) // Pass runtime userId
  else
    const Center(child: CircularProgressIndicator()), // loading fallback
];


    final items = <Widget>[
      const Icon(Icons.home, size: 25, color: Colors.black),
      const Icon(Icons.search, size: 25, color: Colors.black),
      const Icon(Icons.camera, size: 25, color: Colors.black),
      const Icon(Icons.more, size: 25, color: Colors.black),
      const Icon(Icons.settings, size: 25, color: Colors.black),
    ];

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          index: _currentIndex,
          items: items,
          backgroundColor: Colors.transparent,
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          height: 55,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
