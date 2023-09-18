import 'package:flutter/foundation.dart';

class BrowserModel extends ChangeNotifier {
  String _currentUrl = "https://www.google.com/";
  List<String> _bookmarks = [];

  String get currentUrl => _currentUrl;
  List<String> get bookmarks => _bookmarks;

  void updateUrl(String newUrl) {
    _currentUrl = newUrl;
    notifyListeners();
  }

  void addBookmark(String url) {
    _bookmarks.add(url);
    notifyListeners();
  }

  void removeBookmark(int index) {
    if (index >= 0 && index < _bookmarks.length) {
      _bookmarks.removeAt(index);
      notifyListeners();
    }
  }
}
