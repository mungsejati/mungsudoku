import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_profile_repository.dart';

/// The Mental Focus & Productivity Dashboard
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileDataProvider);
    final hours = profile.silentProductivityTimeInMinutes ~/ 60;
    final minutes = profile.silentProductivityTimeInMinutes % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0092DF)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mental Focus',
          style: TextStyle(
            color: Color(0xFF0092DF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              _ProfileHeader(
                userName: profile.userName,
                title: profile.title,
                avatarAsset: profile.avatarAsset,
              ),
              const SizedBox(height: 40),
              
              // Productivity Metrics
              const Text(
                'Productivity Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A5A5A),
                ),
              ),
              const SizedBox(height: 16),
              
              // Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.85, // Adjust for pill/rounded rect shape
                children: [
                  _MetricCard(
                    title: 'Games Played',
                    value: profile.gamesPlayed.toString(),
                    subtitle: '${profile.winRate}% Win Rate',
                    iconData: Icons.sports_esports_rounded,
                  ),
                  _MetricCard(
                    title: 'Focus Streak',
                    value: '${profile.dailyFocusStreak}',
                    subtitle: 'Days',
                    iconData: Icons.local_fire_department_rounded,
                  ),
                  _MetricCard(
                    title: 'Deep Work',
                    value: '${profile.deepWorkSessions}',
                    subtitle: '0 Mistakes',
                    iconData: Icons.psychology_rounded,
                  ),
                  _MetricCard(
                    title: 'Silent Time',
                    value: '${hours}h ${minutes}m',
                    subtitle: 'Total Playtime',
                    iconData: Icons.timer_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String title;
  final String avatarAsset;

  const _ProfileHeader({
    required this.userName,
    required this.title,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8FF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0092DF),
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330092DF),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SvgPicture.asset(
              avatarAsset,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0092DF),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x1A0092DF), // 10% opacity of #0092DF
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0092DF),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData iconData;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 32,
            color: const Color(0xFF0092DF),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
