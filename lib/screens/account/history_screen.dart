import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../models/cafe_model.dart';
import '../production/result_screen.dart';
import '../../mock/mock_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── ELEGANT HEADER ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.charcoal,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    "MY VISIONS",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 3),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.3), AppTheme.charcoal],
                      ),
                    ),
                  ),
                ),
              ),

              // ── MASONRY-STYLE GALLERY ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: FutureBuilder<List<CafeModel>>(
                  future: context.read<StorageService>().loadCafes(),
                  builder: (context, snapshot) {
                    final cafes = snapshot.data ?? [];
                    if (cafes.isEmpty) return _buildEmptyState();

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cafe = cafes[index];
                          // Find style object for ResultScreen
                          final style = MockData.styles.firstWhere(
                            (s) => s.name == cafe.styleName,
                            orElse: () => MockData.styles.first,
                          );

                          return _GalleryCard(
                            cafe: cafe,
                            index: index,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(
                                  originalPath: cafe.originalImagePath,
                                  resultPath: cafe.resultImagePath,
                                  style: style,
                                  settings: cafe.settings,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
                        },
                        childCount: cafes.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── FLOATING STATS OVERLAY ──────────────────────────────────────
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF161A21).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: FutureBuilder<List<CafeModel>>(
                future: context.read<StorageService>().loadCafes(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.mossGreen, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        "$count DESIGNS CREATED",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_outlined, color: Colors.white.withValues(alpha: 0.1), size: 100),
          const SizedBox(height: 24),
          const Text("EMPTY GALLERY", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text("Start your first design vision from home screen.", style: TextStyle(color: Colors.white12, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final CafeModel cafe;
  final int index;
  final VoidCallback onTap;

  const _GalleryCard({required this.cafe, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Alternate height logic for masonry feel if using different layout, 
    // here we use uniform aspect ratio but different inner layout.
    final bool isWide = index % 3 == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(cafe.resultImagePath),
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
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.styleName.toUpperCase(),
                      style: const TextStyle(color: AppTheme.mossGreen, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(cafe.timestamp),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover);
    return Image.file(File(path), fit: BoxFit.cover);
  }

  String _formatDate(DateTime dt) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }
}
