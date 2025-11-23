import 'package:shared_preferences/shared_preferences.dart';
import 'package:utspam_c3_if5a_0018/models/user_model.dart';
import 'package:utspam_c3_if5a_0018/models/rental_model.dart';

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

  // Rental Management
  static Future<void> saveRental(Rental rental) async {
    final prefs = await SharedPreferences.getInstance();
    final rentals = await getRentals();
    rentals.add(rental);
    
    final rentalsData = rentals.map((r) => _rentalToMap(r)).toList();
    await prefs.setStringList(_rentalsKey, rentalsData.map((m) => m.toString()).toList());
  }

  static Future<List<Rental>> getRentals() async {
    final prefs = await SharedPreferences.getInstance();
    final rentalsData = prefs.getStringList(_rentalsKey) ?? [];
    
    return rentalsData.map((data) {
      final map = _parseMapString(data);
      return Rental(
        id: map['id'],
        carId: map['carId'],
        carName: map['carName'],
        carType: map['carType'],
        carImage: map['carImage'],
        customerName: map['customerName'],
        duration: int.parse(map['duration']),
        startDate: DateTime.parse(map['startDate']),
        totalCost: double.parse(map['totalCost']),
        status: RentalStatus.values.firstWhere(
          (e) => e.toString() == map['status'],
        ),
      );
    }).toList();
  }

  static Future<void> updateRental(Rental updatedRental) async {
    final prefs = await SharedPreferences.getInstance();
    final rentals = await getRentals();
    final index = rentals.indexWhere((r) => r.id == updatedRental.id);
    
    if (index != -1) {
      rentals[index] = updatedRental;
      final rentalsData = rentals.map((r) => _rentalToMap(r)).toList();
      await prefs.setStringList(_rentalsKey, rentalsData.map((m) => m.toString()).toList());
    }
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

  static Map<String, dynamic> _rentalToMap(Rental rental) {
    return {
      'id': rental.id,
      'carId': rental.carId,
      'carName': rental.carName,
      'carType': rental.carType,
      'carImage': rental.carImage,
      'customerName': rental.customerName,
      'duration': rental.duration.toString(),
      'startDate': rental.startDate.toIso8601String(),
      'totalCost': rental.totalCost.toString(),
      'status': rental.status.toString(),
    };
  }

  Future login(String text, String text2) async {}
}
