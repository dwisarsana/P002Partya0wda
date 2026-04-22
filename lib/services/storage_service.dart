import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cafe_model.dart';

class StorageService {
  static const String _historyKey = 'cafe_history';

  Future<void> saveCafes(List<CafeModel> cafes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = cafes.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<CafeModel>> loadCafes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      return CafeModel.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final cafes = await loadCafes();
    final index = cafes.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = cafes[index];
      cafes[index] = CafeModel(
        id: g.id,
        originalImagePath: g.originalImagePath,
        resultImagePath: g.resultImagePath,
        styleName: g.styleName,
        timestamp: g.timestamp,
        settings: g.settings,
        isFavorite: !g.isFavorite,
      );
      await saveCafes(cafes);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_time') ?? true;
  }

  Future<void> completeFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }
}
