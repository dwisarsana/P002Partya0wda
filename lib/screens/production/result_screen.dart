import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import '../../models/cafe_style.dart';

class ResultScreen extends StatefulWidget {
  final String originalPath;
  final String resultPath;
  final CafeStyle style;
  final Map<String, dynamic> settings;

  const ResultScreen({
    super.key,
    required this.originalPath,
    required this.resultPath,
    required this.style,
    required this.settings,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showOriginal = false;
  bool _isProcessing = false;

  Future<void> _shareResult() async {
    setState(() => _isProcessing = true);
    try {
      final response = await http.get(Uri.parse(widget.resultPath));
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/cafe_design_${DateTime.now().millisecondsSinceEpoch}.jpg').create();
      await file.writeAsBytes(response.bodyBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Check out my new ${widget.style.name} cafe design created with Cafe AI!',
      );
    } catch (e) {
      if (mounted) {
        _showToast("Failed to share image", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _downloadImage() async {
    setState(() => _isProcessing = true);
    try {
      // Check permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showToast("Storage permission denied", isError: true);
          return;
        }
      }

      final response = await http.get(Uri.parse(widget.resultPath));
      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: 100,
        name: "cafe_ai_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess'] == true) {
        _showToast("Saved to gallery!");
      } else {
        _showToast("Failed to save image", isError: true);
      }
    } catch (e) {
      _showToast("Error saving image", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppTheme.mossGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // ── MAIN VIEWPORT (IMAGE) ─────────────────────────────────────────
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showOriginal
                  ? Image.file(File(widget.originalPath), key: const ValueKey('original'), fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : Image.network(widget.resultPath, key: const ValueKey('result'), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
          ),

          // ── TOP BAR ACTIONS ──────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleAction(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                    ),
                    Row(
                      children: [
                        _CircleAction(
                          icon: _isProcessing ? Icons.hourglass_empty_rounded : Icons.download_rounded,
                          onTap: _isProcessing ? () {} : _downloadImage,
                        ),
                        const SizedBox(width: 12),
                        _CircleAction(
                          icon: _isProcessing ? Icons.hourglass_empty_rounded : Icons.share_rounded,
                          onTap: _isProcessing ? () {} : _shareResult,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BEFORE/AFTER TOGGLE ──────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: 20,
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) => setState(() => _showOriginal = true),
                  onTapUp: (_) => setState(() => _showOriginal = false),
                  onTapCancel: () => setState(() => _showOriginal = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.mossGreen.withValues(alpha: _showOriginal ? 1.0 : 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Icon(Icons.compare_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("HOLD TO\nCOMPARE", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
              ],
            ),
          ),

          // ── BOTTOM INFO CARD ─────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161A21).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.mossGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.mossGreen, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("DESIGN COMPLETED", style: TextStyle(color: AppTheme.mossGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            Text(widget.style.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("ADJUST SETTINGS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.mossGreen,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text("FINISH", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutQuint),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}