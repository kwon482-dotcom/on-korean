import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_settings.dart';
import '../services/locale_service.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReviewMode;
  final VoidCallback? onFinish;

  const OnboardingScreen({
    super.key,
    this.isReviewMode = false,
    this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _slideCount = 4;

  String _getAssetPath(int index) {
    final langCode = LocaleService.currentLocale.value.languageCode;
    final folder = (langCode == 'ko' || langCode == 'ja') ? langCode : 'en';
    return 'assets/onboarding/$folder/slide_${index + 1}.png';
  }

  Future<void> _completeOnboarding() async {
    if (widget.isReviewMode) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await AppSettings.setHasSeenOnboarding(true);
    widget.onFinish?.call();
  }

  void _nextPage() {
    if (_currentPage < _slideCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F46E5);
    final isLastPage = _currentPage == _slideCount - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 바 (건너뛰기 / 닫기)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.isReviewMode)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        tooltip: 'Close',
                      )
                    else
                      const SizedBox(width: 48),

                    // 건너뛰기 버튼 (마지막 페이지가 아닐 때 노출)
                    if (!isLastPage)
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white60,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          LocaleService.tr('onboarding_skip'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              // 중앙 슬라이드 이미지
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slideCount,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final assetPath = _getAssetPath(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 페이지 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slideCount, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // 하단 액션 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLastPage ? _completeOnboarding : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage
                              ? LocaleService.tr('onboarding_start')
                              : LocaleService.tr('onboarding_next'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastPage
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
