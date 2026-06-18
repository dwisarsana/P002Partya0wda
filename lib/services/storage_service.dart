import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/party_model.dart';

class StorageService {
  static const String _historyKey = 'party_history';

  Future<void> saveParties(List<PartyModel> parties) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = parties.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<PartyModel>> loadParties() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      return PartyModel.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final parties = await loadParties();
    final index = parties.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = parties[index];
      parties[index] = PartyModel(
        id: g.id,
        originalImagePath: g.originalImagePath,
        resultImagePath: g.resultImagePath,
        styleName: g.styleName,
        timestamp: g.timestamp,
        settings: g.settings,
        isFavorite: !g.isFavorite,
      );
      await saveParties(parties);
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
