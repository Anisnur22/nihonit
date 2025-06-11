import 'package:flutter/material.dart';
import 'package:coolapp/pages/account/login_page.dart';
import 'package:coolapp/pages/account/register_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    // Offset Animation for moving widgets upward
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Initial off-screen position
      end: Offset.zero, // End position at their original place
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Opacity Animation for smooth fade-in effect
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SlideTransition(
                position: _offsetAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 240,
                    ),
                  ),
                ),
              ),
              // Title Text
              SlideTransition(
                position: _offsetAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subtitle Text
              SlideTransition(
                position: _offsetAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: const Text(
                    'Your first step to fluency in Japanese starts here.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Register Button
                  SlideTransition(
                    position: _offsetAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        ),
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                            color: Color(0xFFBC002D), // Dark Red
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Log In Button
                  SlideTransition(
                    position: _offsetAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        ),
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Color(0xFFBC002D), // Dark Red
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the controller when done
    _controller.dispose();
    super.dispose();
  }
}
