import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3)); // Wait for animation
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Stack(
        fit: StackFit.expand, // Fill screen
        children: [
          // LAYER 1: Logo (Background/Bottom)
          Column(
            children: [
               const Spacer(flex: 3), // Push logo down
               Transform.scale(
                 scale: 5.0,
                 child: SizedBox(
                   width: 200,
                   child: Lottie.asset(
                     'assets/lg.json',
                     fit: BoxFit.contain,
                     repeat: true, // Force repeat to ensure visibility of animation
                     animate: true,
                   ),
                 ),
               ),
               const Spacer(flex: 1), 
            ],
          ),
          
          // LAYER 2: Illustration (Foreground/Top)
          Positioned(
            top: 60, // Safe area space
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Image.asset(
              'assets/splash.png',
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }
}
