import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main/main_screen.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "Discover Your\nCafe Style",
      description:
          "From Minimalist Zen to Industrial Chic, explore a library of expert-curated interior themes.",
      image: 'assets/images/cafe_workflow.jpeg',
      icon: Icons.auto_awesome_mosaic_rounded,
    ),
    OnboardingStep(
      title: "Design with\nAI Intelligence",
      description:
          "Upload a photo of your space and watch as our AI creates professional-grade redesigns in seconds.",
      image: 'assets/images/cafe_hero_dark.jpeg',
      icon: Icons.bolt_rounded,
    ),
    OnboardingStep(
      title: "Precision\nCustomization",
      description:
          "Fine-tune every detail from lighting intensity to furniture density to create your unique vision.",
      image: 'assets/images/styles/industrial_roastery.jpeg',
      icon: Icons.tune_rounded,
    ),
  ];

  void _finishOnboarding() async {
    final storage = context.read<StorageService>();
    await storage.completeFirstTime();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Stack(
        children: [
          // MAIN PAGE VIEW
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Immersive Background Image
                  Image.asset(step.image, fit: BoxFit.cover),
                  
                  // Gradient Overlay (Bottom-Heavy)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.charcoal.withValues(alpha: 0.2),
                          AppTheme.charcoal.withValues(alpha: 0.9),
                          AppTheme.charcoal,
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // CONTENT AREA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.mossGreen.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
                          ),
                          child: Icon(step.icon, color: AppTheme.mossGreen, size: 40),
                        ).animate(key: ValueKey('icon_$index')).scale().fadeIn(),
                        const SizedBox(height: 32),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ).animate(key: ValueKey('title_$index')).fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 20),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ).animate(key: ValueKey('desc_$index')).fadeIn(delay: 400.ms),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // BOTTOM CONTROL BAR
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicators
                Row(
                  children: List.generate(
                    _steps.length,
                    (idx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == idx ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _currentPage == idx ? AppTheme.mossGreen : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Action Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _steps.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutQuint,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.mossGreen,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mossGreen.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentPage == _steps.length - 1 ? "GET STARTED" : "NEXT",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ).animate().shimmer(delay: 2.seconds, duration: 2.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
