import 'package:flutter/material.dart';
import '../utils/prefs_helper.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggle(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    PrefsHelper.saveFavorites(_favoriteIds);
  }

  int get count => _favoriteIds.length;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Future<void> loadFromPrefs() async {
    final saved = await PrefsHelper.loadFavorites();
    _favoriteIds.addAll(saved);
    notifyListeners();
  }
}
