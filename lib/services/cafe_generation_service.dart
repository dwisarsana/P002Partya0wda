import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../safe_prompt_filter.dart';

// ── EXCEPTIONS ──────────────────────────────────────────────────────────────

class UnsafePromptException implements Exception {
  UnsafePromptException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => message;
}

// ── CONFIGURATION ───────────────────────────────────────────────────────────

/// Configuration for image generation that controls how similar
/// the output is to the input image.
class GenerationConfig {
  /// How much to preserve the original room structure (0.0 - 1.0).
  final double structureStrength;

  /// How much the output should resemble the input image (0.0 - 1.0).
  final double imageStrength;

  /// How closely to follow the text prompt (1.0 - 30.0).
  final double guidanceScale;

  /// Number of inference steps. More = higher quality but slower.
  final int numInferenceSteps;

  final String outputFormat;
  final int outputQuality;

  const GenerationConfig({
    this.structureStrength = 0.92,
    this.imageStrength = 0.88,
    this.guidanceScale = 7.5,
    this.numInferenceSteps = 30,
    this.outputFormat = 'jpg',
    this.outputQuality = 100,
  });

  factory GenerationConfig.subtle() => const GenerationConfig(
    structureStrength: 0.95,
    imageStrength: 0.92,
    guidanceScale: 5.0,
    numInferenceSteps: 35,
  );

  factory GenerationConfig.balanced() => const GenerationConfig(
    structureStrength: 0.92,
    imageStrength: 0.85,
    guidanceScale: 7.5,
    numInferenceSteps: 30,
  );

  factory GenerationConfig.creative() => const GenerationConfig(
    structureStrength: 0.85,
    imageStrength: 0.75,
    guidanceScale: 10.0,
    numInferenceSteps: 30,
  );
}

// ── PROMPT BUILDER ──────────────────────────────────────────────────────────

/// Builds an optimised Imagen / Replicate prompt from the settings that the
/// user selected in [CustomStudioScreen].
class CafePromptBuilder {
  static String build({
    required String styleName,
    required Map<String, dynamic> settings,
  }) {
    // ── PRIORITY: CUSTOM PROMPT FROM UI ──────────────────────────────────
    final customPrompt = settings['customPrompt'] as String?;
    if (customPrompt != null && customPrompt.trim().isNotEmpty) {
      return customPrompt.trim();
    }

    final parts = <String>[];

    // ── Preservation prefix ──────────────────────────────────────────────
    parts.add(
      'Transform this existing cafe photo while preserving the '
      'exact same camera angle, perspective, spatial layout, '
      'and surrounding architecture.',
    );

    // ── Style ────────────────────────────────────────────────────────────
    parts.add('Apply a $styleName cafe design style.');

    // ── Ambiance ──────────────────────────────────────────────────────────
    final season = settings['season'] as String?;
    if (season != null && season.isNotEmpty) {
      parts.add(
        'Set the cafe in $season season with appropriate seasonal '
        'plants, colors, and atmosphere.',
      );
    }
    final timeOfDay = settings['timeOfDay'] as String?;
    if (timeOfDay != null && timeOfDay.isNotEmpty) {
      parts.add('Lighting should reflect $timeOfDay ambiance.');
    }
    final sunlight = (settings['sunlight'] as num?)?.toDouble() ?? 0.7;
    final lightDesc = sunlight > 0.6
        ? 'bright, sun-drenched'
        : sunlight > 0.3
        ? 'partially shaded, dappled light'
        : 'softly shaded, cool tones';
    parts.add('Cafe has $lightDesc sunlight conditions.');
    final vibrancy = (settings['colorVibrancy'] as num?)?.toDouble() ?? 0.6;
    if (vibrancy > 0.7) {
      parts.add('Bold, vibrant color palette with high saturation.');
    } else if (vibrancy < 0.3) {
      parts.add('Muted, neutral, and earthy tones throughout.');
    }

    // ── Seating density ────────────────────────────────────────────────────
    final density = (settings['density'] as num?)?.toDouble() ?? 0.5;
    if (density > 0.7) {
      parts.add(
        'Dense, crowded seating arrangement with maximal tables and chairs.',
      );
    } else if (density < 0.3) {
      parts.add(
        'Sparse, spacious seating arrangement with open space and breathing room.',
      );
    } else {
      parts.add('Balanced seating density with well-spaced tables.');
    }

    // ── Table size ─────────────────────────────────────────────────
    final tableSize = (settings['tableSize'] as num?)?.toDouble() ?? 0.3;
    if (tableSize > 0.6) {
      parts.add('Include large communal tables and spacious group seating.');
    } else if (tableSize > 0.2) {
      parts.add('Moderate sized tables for typical cafe seating.');
    } else {
      parts.add('Small bistro tables and intimate seating only.');
    }

    // ── Bar scale ────────────────────────────────────────────────────────
    final barScale = (settings['barScale'] as num?)?.toDouble() ?? 0.5;
    if (barScale > 0.7) {
      parts.add('Include a grand, prominent espresso bar and counter area.');
    } else if (barScale < 0.3) {
      parts.add('Minimalist, compact espresso counter.');
    }

    // ── Decor Scale ────────────────────────────────────────────────────────────
    final decorScale = (settings['decorScale'] as num?)?.toDouble() ?? 0.0;
    if (decorScale > 0.4) {
      parts.add('Include eclectic and prominent cafe decor.');
    }

    // ── Decor Feature Type ────────────────────────────────────────────────────
    final decorFeatureIdx = (settings['decorFeature'] as num?)?.toInt() ?? -1;
    const decorFeatures = [
      'Coffee Roaster',
      'Bookshelves',
      'Hanging Plants',
      'Local Art',
      'Vintage Mirrors',
      'Record Player',
      'Chalkboard Menu',
      'Macrame Wall',
      'Pastry Display',
      'Fireplace',
      'Neon Wall Art',
      'Bicycles',
    ];
    if (decorFeatureIdx >= 0 && decorFeatureIdx < decorFeatures.length) {
      parts.add(
        'Include a decorative ${decorFeatures[decorFeatureIdx]} as a focal point.',
      );
    }

    // ── Flooring ──────────────────────────────────────────────────────────
    final flooringIdx = (settings['flooring'] as num?)?.toInt() ?? 0;
    const flooringMaterials = [
      'checkered tile',
      'polished concrete',
      'vintage wood',
      'terrazzo',
      'herringbone',
      'exposed brick',
      'hexagon tile',
      'marble slab',
      'carpeted',
      'painted wood',
    ];
    if (flooringIdx < flooringMaterials.length) {
      parts.add(
        'Flooring is made of ${flooringMaterials[flooringIdx]} material.',
      );
    }

    // ── Lighting fixture ─────────────────────────────────────────────────
    final lightingIdx = (settings['lighting'] as num?)?.toInt() ?? 0;
    const lightingNames = [
      'edison pendants',
      'track lighting',
      'neon signs',
      'brass chandeliers',
      'wall sconces',
      'natural skylights',
      'library lamps',
      'paper lanterns',
      'industrial domes',
      'fairy string lights',
    ];
    if (lightingIdx < lightingNames.length) {
      parts.add('Cafe lighting uses ${lightingNames[lightingIdx]}.');
    }

    // ── Quality suffix ───────────────────────────────────────────────────
    parts.add(
      'Photorealistic result, professional interior cafe photography, '
      'consistent lighting and shadows, high resolution, 8K quality, '
      'maintaining exact same cafe proportions and surroundings.',
    );

    return parts.join(' ');
  }
}

// ── API CLIENT ──────────────────────────────────────────────────────────────

class ReplicateCafeAIService {
  ReplicateCafeAIService({SafePromptFilter? filter})
    : _filter = filter ?? SafePromptFilter(mode: 'strict');

  static const _apiToken = 'API_KEY';
  static const _model = 'google/nano-banana';

  final _client = http.Client();
  final SafePromptFilter _filter;

  Future<String?> generateMultiBytes({
    required List<Uint8List> images,
    required String prompt,
    GenerationConfig config = const GenerationConfig(),
  }) async {
    final check = _filter.check(prompt);
    if (!check.allowed) {
      throw UnsafePromptException(
        'Your prompt violates our content policy: "${check.reason}"',
      );
    }

    final dataUrls = <String>[];
    for (final bytes in images) {
      dataUrls.add(await _bytesToDataUrl(bytes));
    }

    final body = {
      'version': _model,
      'input': {
        'prompt': check.sanitized,
        'negative_prompt': 'blurry, low quality, distorted, cartoon, sketch',
        'image_input': dataUrls,
        'structure_strength': config.structureStrength,
        'image_strength': config.imageStrength,
        'guidance_scale': config.guidanceScale,
        'num_inference_steps': config.numInferenceSteps,
        'output_format': config.outputFormat,
        'output_quality': config.outputQuality,
      },
    };

    try {
      final res = await _client.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Prefer': 'wait',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode != 201 && res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final output = data['output'];
      if (output is List && output.isNotEmpty) return output[0] as String;
      if (output is String) return output;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _bytesToDataUrl(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return 'data:image/png;base64,${base64Encode(bytes)}';

    final resized = img.copyResize(decoded, width: 1024);
    final out = img.encodeJpg(resized, quality: 85);
    return 'data:image/jpeg;base64,${base64Encode(out)}';
  }

  void dispose() => _client.close();
}

// ── MAIN WRAPPER SERVICE ────────────────────────────────────────────────────

class CafeGenerationService {
  CafeGenerationService()
    : _api = ReplicateCafeAIService(filter: SafePromptFilter(mode: 'strict'));

  final ReplicateCafeAIService _api;

  Future<String?> generate({
    required String imagePath,
    required String styleName,
    required Map<String, dynamic> settings,
    GenerationConfig config = const GenerationConfig(),
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final prompt = CafePromptBuilder.build(
      styleName: styleName,
      settings: settings,
    );
    debugPrint('[CafeGeneration] Prompt: $prompt');

    return _api.generateMultiBytes(
      images: [bytes],
      prompt: prompt,
      config: config,
    );
  }

  void dispose() => _api.dispose();
}
