import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parallax_button.dart';
import '../../widgets/glass_container.dart';
import '../../mock/mock_data.dart';
import '../../models/party_model.dart';
import '../../services/storage_service.dart';
import '../account/history_screen.dart';
import '../account/settings_screen.dart';
import '../production/upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildHistoryImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImg());
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _errorImg());
    }
    return _errorImg();
  }

  Widget _errorImg() => Container(
        color: AppTheme.charcoal.withValues(alpha: 0.1),
        child: const Icon(Icons.broken_image_rounded,
            color: AppTheme.slate, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient base
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1D23),
                  Color(0xFF0F1117),
                ],
              ),
            ),
          )),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── MODERN MINIMALIST HEADER ─────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PARTY AI",
                              style: TextStyle(
                                color: AppTheme.mossGreen,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              "Creator Studio",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _MinimalActionIcon(
                              icon: Icons.history_rounded,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HistoryScreen())),
                            ),
                            const SizedBox(width: 12),
                            _MinimalActionIcon(
                              icon: Icons.settings_rounded,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsScreen())),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── MAIN BENTO GRID ───────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Hero Card (Large Bento)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            image: const DecorationImage(
                              image: AssetImage("assets/images/party_hero_dark.jpeg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: AppTheme.sunGlow, size: 28),
                                SizedBox(height: 8),
                                Text(
                                  "New Design Vision",
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Transform your space with AI",
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().scale(delay: 100.ms),

                      const SizedBox(height: 16),

                      // Secondary Bento Row
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _BentoActionCard(
                              title: "Browse\nStyles",
                              subtitle: "100+ Themes",
                              icon: Icons.dashboard_customize_rounded,
                              color: AppTheme.mossGreen,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
                            ).animate().slideX(begin: -0.2, delay: 200.ms),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _BentoActionCard(
                              title: "Daily\nQuota",
                              subtitle: "Premium",
                              icon: Icons.bolt_rounded,
                              color: AppTheme.sunGlow,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ).animate().slideX(begin: 0.2, delay: 300.ms),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── RECENT PROJECTS (HORIZONTAL) ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Visions",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        child: Text("See all", style: TextStyle(color: AppTheme.mossGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FutureBuilder<List<PartyModel>>(
                  future: context.read<StorageService>().loadParties(),
                  builder: (context, snapshot) {
                    final parties = snapshot.data ?? [];
                    if (parties.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Center(
                            child: Text("Your redesigned parties will appear here.", style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ),
                        ),
                      );
                    }
                    
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: parties.length,
                        itemBuilder: (context, index) {
                          final party = parties[index];
                          return _HistoryBentoCard(
                            party: party,
                            imageBuilder: _buildHistoryImage,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          ).animate().fadeIn(delay: (400 + index * 100).ms);
                        },
                      ),
                    );
                  },
                ),
              ),

              // ── TRENDING THEMES GRID ─────────────────────────────────────────
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trending Themes",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text("Curated by our expert designers", 
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final style = MockData.styles[index];
                      return _TrendingBentoCard(
                        style: style,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
                      ).animate().fadeIn(delay: (500 + index * 50).ms);
                    },
                    childCount: MockData.styles.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinimalActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MinimalActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _BentoActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BentoActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, height: 1.1, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBentoCard extends StatelessWidget {
  final PartyModel party;
  final Widget Function(String) imageBuilder;
  final VoidCallback onTap;

  const _HistoryBentoCard({required this.party, required this.imageBuilder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.sunGlow.withValues(alpha: 0.3), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageBuilder(party.resultImagePath),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  party.styleName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingBentoCard extends StatelessWidget {
  final dynamic style; // PartyStyle
  final VoidCallback onTap;

  const _TrendingBentoCard({required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.asset(style.imagePath, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(style.difficulty, style: TextStyle(color: AppTheme.mossGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

