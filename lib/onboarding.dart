import 'package:flutter/material.dart';
import 'package:zekink/login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final int totalPages = 3;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${currentPage + 1}/$totalPages",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: LinearProgressIndicator(
                        value: (currentPage + 1) / totalPages,
                        backgroundColor: Colors.grey[300],
                        color: const Color(0xFF6A11CB),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(totalPages - 1);
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                  children: [
                    OnboardingStep(
                      imagePath: 'assets/images/step1.png',
                      title: "Welcome to Zekink!",
                      subtitle: "Smart pen technology that helps parents track their child's learning progress, focus levels, and study habits. Make learning more engaging and effective with AI-powered insights.",
                      buttonText: "Continue",
                      onNext: () {
                        _handleNextPage();
                      },
                    ),
                    OnboardingStep(
                      imagePath: 'assets/images/step2.png',
                      title: "Real-Time Monitoring",
                      subtitle: "Track your child's focus, writing pressure, and study patterns in real-time. Get instant notifications about attention drops and receive personalized recommendations to improve learning outcomes.",
                      buttonText: "Continue",
                      onNext: () {
                        _handleNextPage();
                      },
                    ),
                    OnboardingStep(
                      imagePath: 'assets/images/step3.png',
                      title: "Parental Dashboard",
                      subtitle: "Access comprehensive analytics about your child's learning journey. Monitor progress, set study goals, and create a supportive learning environment with data-driven insights.",
                      buttonText: "Get Started",
                      onNext: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage()
                          ),
                        );
                      },
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

  void _handleNextPage() {
    final nextPage = currentPage + 1;
    if (nextPage < totalPages) {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

class OnboardingStep extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onNext;

  const OnboardingStep({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 270,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 70),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A11CB),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16, 
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}