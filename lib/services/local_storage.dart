import 'package:shared_preferences/shared_preferences.dart';
import 'package:utspam_c3_if5a_0018/models/user_model.dart';

class LocalStorageService {
  static const String _userKey = 'current_user';
  static const String _rentalsKey = 'rentals';

  // User Management
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toMap().toString());
  }

  static Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      // Parse dari string ke Map
      final map = _parseMapString(userData);
      return User.fromMap(map);
    }
    return null;
  }

  static Future<void> setLoggedInUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toMap().toString());
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hanya hapus status login, bukan data user
    await prefs.remove('loggedInUser');
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final map = _parseMapString(userData);
      return User.fromMap(map);
    }
    return null;
  }

  
  // Helper methods
  static Map<String, dynamic> _parseMapString(String mapString) {
    final result = <String, dynamic>{};
    final pairs = mapString.substring(1, mapString.length - 1).split(', ');
    
    for (final pair in pairs) {
      final keyValue = pair.split(': ');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim();
        final value = keyValue[1].trim();
        result[key] = value;
      }
    }
    
    return result;
  }


  Future login(String text, String text2) async {}
}
