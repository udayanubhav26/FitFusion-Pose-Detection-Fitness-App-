import 'package:flutter/material.dart';
import 'package:ui/main.dart';
import 'signin.dart'; // SignUp page
// Home page

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> images = const [
    'assets/Images/intro.png',
    'assets/Images/pushup.png',
    'assets/Images/strech.png',
  ];

  final List<String> titles = const [
    'Welcome to FitFusion',
    'Track Your Progress',
    'Stay Motivated',
  ];

  final List<String> subtitles = const [
    'Find your inner peace with daily yoga exercises.',
    'See how far you’ve come and improve daily.',
    'Get reminders and tips to keep going strong.',
  ];

  void _nextPage() {
    if (_currentPage < images.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSignUp();
    }
  }

  void _goToSignUp() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnim =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(animation);
          final fadeAnim = Tween<double>(begin: 0, end: 1).animate(animation);
          return SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _skipIntro() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(userName: "Guest"),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnim =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(animation);
          final fadeAnim = Tween<double>(begin: 0, end: 1).animate(animation);
          return SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : Colors.white54,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with images, title, subtitle
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlueAccent, Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: _currentPage == index ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: 300,
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      titles[index],
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      subtitles[index],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Dots indicator
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: _buildDots(),
          ),

          // Next / Get Started button at bottom center
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  _currentPage == images.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Skip button at top-right corner
  // Skip button at top-right corner
Positioned(
  top: 40,
  right: 20,
  child: ElevatedButton(
    onPressed: _skipIntro,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: Colors.white,
      elevation: 4,
    ),
    child: const Text(
      'Skip',
      style: TextStyle(
        color: Colors.blueAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),


        ],
      ),
    );
  }
}
