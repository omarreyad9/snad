import 'package:flutter/material.dart';
import 'package:muse/screens/welcome_screen.dart';

/// Three-step MUSE onboarding:
/// 1) Introduction, 2) Discover your style, 3) The original WelcomeScreen.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onExploreAsGuest;

  const OnboardingScreen({
    super.key,
    required this.onCreateAccount,
    required this.onExploreAsGuest,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 2) _goToPage(_currentPage + 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _IntroPage(
            imageUrl:
                'https://images.pexels.com/photos/5709665/pexels-photo-5709665.jpeg?auto=compress&cs=tinysrgb&w=1200',
            eyebrow: 'WELCOME TO MUSE',
            firstLine: 'Style begins',
            secondLine: 'with you.',
            description:
                'A thoughtful space for discovering pieces that feel like they were made for you.',
            pageNumber: 0,
            onContinue: _nextPage,
            onSkip: () => _goToPage(2),
          ),
          _IntroPage(
            imageUrl:
                'https://images.pexels.com/photos/7691168/pexels-photo-7691168.jpeg?auto=compress&cs=tinysrgb&w=1200',
            eyebrow: 'DISCOVER YOUR LOOK',
            firstLine: 'Find your',
            secondLine: 'own style.',
            description:
                'Explore timeless essentials and expressive pieces, then make every look your own.',
            pageNumber: 1,
            onContinue: _nextPage,
            onSkip: () => _goToPage(2),
          ),
          WelcomeScreen(
            onStart: widget.onCreateAccount,
            onGuest: widget.onExploreAsGuest,
          ),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final String imageUrl;
  final String eyebrow;
  final String firstLine;
  final String secondLine;
  final String description;
  final int pageNumber;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _IntroPage({
    required this.imageUrl,
    required this.eyebrow,
    required this.firstLine,
    required this.secondLine,
    required this.description,
    required this.pageNumber,
    required this.onContinue,
    required this.onSkip,
  });

  static const Color background = Color(0xFFF8F5F1);
  static const Color brown = Color(0xFF4A382D);
  static const Color softBrown = Color(0xFF9A7863);
  static const Color lightBrown = Color(0xFFBFA18D);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = (screenHeight * 0.48).clamp(270.0, 430.0);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                      color: Color(0xFFEEE9E2),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: softBrown,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF31231B).withOpacity(0.12),
                          const Color(0xFF31231B).withOpacity(0.48),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 52,
                    left: 28,
                    child: Text(
                      'MUSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 44,
                    right: 20,
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 10,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 22,
                    left: 28,
                    child: Text(
                      'THE MUSE EDIT  /  0${pageNumber + 1}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 25, 28, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 13, color: softBrown),
                        SizedBox(width: 7),
                      ],
                    ),
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.35,
                        color: softBrown,
                      ),
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 46,
                          height: 1.0,
                          color: brown,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(text: '$firstLine\n'),
                          TextSpan(
                            text: secondLine,
                            style: const TextStyle(
                              color: lightBrown,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: Color(0xFF826A5A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A6B56),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final selected = index == pageNumber;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 23 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: selected
                                  ? softBrown
                                  : const Color(0xFFD9CEC5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}