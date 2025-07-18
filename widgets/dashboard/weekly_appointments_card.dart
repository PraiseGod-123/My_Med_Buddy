// lib/widgets/dashboard/health_tips_card.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';

class HealthTipsCard extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onMoreTips;

  const HealthTipsCard({Key? key, this.onTap, this.onMoreTips})
    : super(key: key);

  @override
  State<HealthTipsCard> createState() => _HealthTipsCardState();
}

class _HealthTipsCardState extends State<HealthTipsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentTipIndex = 0;
  late PageController _pageController;

  final List<HealthTip> _healthTips = [
    HealthTip(
      title: 'Stay Hydrated',
      description:
          'Drink at least 8 glasses of water daily. Proper hydration helps your body function optimally and can improve energy levels.',
      icon: Icons.water_drop,
      color: Colors.blue,
      category: 'Hydration',
    ),
    HealthTip(
      title: 'Take Your Medications',
      description:
          'Take medications as prescribed by your doctor. Set reminders to help maintain consistency.',
      icon: Icons.medication,
      color: AppColors.primaryColor,
      category: 'Medication',
    ),
    HealthTip(
      title: 'Get Quality Sleep',
      description:
          'Aim for 7-9 hours of sleep each night. Good sleep is essential for physical and mental health.',
      icon: Icons.bedtime,
      color: Colors.indigo,
      category: 'Sleep',
    ),
    HealthTip(
      title: 'Exercise Regularly',
      description:
          'Engage in at least 30 minutes of moderate exercise daily. Physical activity boosts mood and energy.',
      icon: Icons.fitness_center,
      color: Colors.green,
      category: 'Exercise',
    ),
    HealthTip(
      title: 'Eat Balanced Meals',
      description:
          'Include fruits, vegetables, and whole grains in your diet. Balanced nutrition supports overall health.',
      icon: Icons.restaurant,
      color: Colors.orange,
      category: 'Nutrition',
    ),
    HealthTip(
      title: 'Manage Stress',
      description:
          'Practice relaxation techniques like deep breathing or meditation to reduce stress levels.',
      icon: Icons.self_improvement,
      color: Colors.purple,
      category: 'Mental Health',
    ),
    HealthTip(
      title: 'Regular Check-ups',
      description:
          'Schedule regular appointments with your healthcare provider for preventive care.',
      icon: Icons.medical_services,
      color: Colors.teal,
      category: 'Healthcare',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Auto-rotate tips every 10 seconds
    _startAutoRotation();
  }

  void _startAutoRotation() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _nextTip();
        _startAutoRotation();
      }
    });
  }

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length;
    });

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousTip() {
    setState(() {
      _currentTipIndex =
          (_currentTipIndex - 1 + _healthTips.length) % _healthTips.length;
    });

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildTipContent(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Health Tip of the Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _healthTips[_currentTipIndex].color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _healthTips[_currentTipIndex].category,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _healthTips[_currentTipIndex].color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipContent() {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTipIndex = index % _healthTips.length;
          });
        },
        itemBuilder: (context, index) {
          final tip = _healthTips[index % _healthTips.length];
          return _buildTipCard(tip);
        },
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, color: tip.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Navigation arrows
        Row(
          children: [
            GestureDetector(
              onTap: _previousTip,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _nextTip,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // Page indicators
        Expanded(
          child: Row(
            children: List.generate(_healthTips.length, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: index == _currentTipIndex ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentTipIndex
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),

        // More tips button
        GestureDetector(
          onTap: widget.onMoreTips ?? _showMoreTips,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'More Tips',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreTips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Health Tips Library',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _healthTips.length,
                      itemBuilder: (context, index) {
                        final tip = _healthTips[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tip.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: tip.color.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: tip.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  tip.icon,
                                  color: tip.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tip.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: tip.color.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            tip.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: tip.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tip.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}
