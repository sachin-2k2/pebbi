import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/welcome_page_data.dart';
import '../widgets/splash/splash_config.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/welcome_bottom_bar.dart';
import '../widgets/welcome_card.dart';

/// Welcome intro screen featuring a PageView of value proposition cards.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, build under 50 lines,
/// no helper widget methods, handles landscape & 200% text scaling via scrolling.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.pages = WelcomePageData.mockPages,
    this.totalPageCount = 3,
    this.onComplete,
    this.onSkip,
  });

  final List<WelcomePageData> pages;
  final int totalPageCount;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
        debugPrint(
          '[SPLASH_TIMING] WelcomeScreen first interactive frame rendered at ${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleNext() {
    if (_currentIndex < widget.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go('/onboarding/setup');
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go('/onboarding/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = widget.pages[_currentIndex];

    return StepScaffold(
      isScrollable: false,
      onSkip: _handleSkip,
      bottomBar: WelcomeBottomBar(
        currentIndex: _currentIndex,
        pageCount: widget.totalPageCount,
        data: currentData,
        onNext: _handleNext,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.pages.length,
        itemBuilder: (context, index) {
          return Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: WelcomeCard(data: widget.pages[index]),
            ),
          );
        },
      ),
    );
  }
}
