import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/cafe_model.dart';
import '../../models/cafe_style.dart';
import '../../services/cafe_generation_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'result_screen.dart';
import '../../src/constant.dart';

class GeneratingScreen extends StatefulWidget {
  final String imagePath;
  final CafeStyle style;
  final Map<String, dynamic> settings;

  const GeneratingScreen({
    super.key,
    required this.imagePath,
    required this.style,
    required this.settings,
  });

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  final _service = CafeGenerationService();

  String _statusMessage = 'Analyzing your cafe...';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _generate();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final messages = [
      (0.1, 'Extracting spatial data...'),
      (0.3, 'Refining style parameters...'),
      (0.5, 'AI Engine initializing...'),
      (0.7, 'Applying design layers...'),
      (0.9, 'Polishing lighting & textures...'),
    ];

    for (final (p, msg) in messages) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() {
        _progress = p;
        _statusMessage = msg;
      });
    }

    try {
      final resultUrl = await _service.generate(
        imagePath: widget.imagePath,
        styleName: widget.style.name,
        settings: widget.settings,
      );

      if (!mounted) return;

      if (resultUrl == null) {
        setState(() {
          _hasError = true;
          _errorMsg = 'AI was unable to complete the transformation. Please adjust your settings and try again.';
        });
        return;
      }

      await PremiumGate.consumeQuotaOrToken();

      setState(() {
        _progress = 1.0;
        _statusMessage = 'Transformation complete!';
      });

      await _saveToHistory(resultUrl);

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            originalPath: widget.imagePath,
            resultPath: resultUrl,
            style: widget.style,
            settings: widget.settings,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg = 'Connection error. Please check your internet and try again.';
      });
    }
  }

  Future<void> _saveToHistory(String resultUrl) async {
    try {
      final storage = context.read<StorageService>();
      final current = await storage.loadCafes();
      final cafe = CafeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalImagePath: widget.imagePath,
        resultImagePath: resultUrl,
        styleName: widget.style.name,
        timestamp: DateTime.now(),
        settings: widget.settings,
      );
      await storage.saveCafes([cafe, ...current]);
      // Statistics updated within consumeQuotaOrToken()
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // Background Original (Blurred)
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ).animate().blur(begin: const Offset(5,5), end: const Offset(20, 20), duration: 2.seconds),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _hasError ? _buildErrorLayout() : _buildProgressLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AI Core Animation
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: _rotateCtrl.value * 6.28,
                  child: child,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.1), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mossGreen),
                    ),
                  ),
                ),
              ),
              Image.asset('assets/icon.png', width: 60, height: 60)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
            ],
          ),
        ),

        const SizedBox(height: 60),

        const Text(
          "REIMAGINING",
          style: TextStyle(color: AppTheme.mossGreen, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 4),
        ).animate().fadeIn(),

        const SizedBox(height: 12),

        Text(
          widget.style.name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: 2),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 32),

        // Status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            _statusMessage,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ).animate(key: ValueKey(_statusMessage)).fadeIn().slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildErrorLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
        const SizedBox(height: 32),
        const Text(
          "PROCESS INTERRUPTED",
          style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Text(
          _errorMsg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.6),
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE STUDIO", style: TextStyle(color: Colors.white38)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () { setState(() => _hasError = false); _generate(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mossGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("RETRY NOW", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn();
  }
}
