import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// class SettingsRepository {
//   late SharedPreferences _sharedPreferences;

//   Future<void> init() async {
//     _sharedPreferences = await SharedPreferences.getInstance();

//     if (_sharedPreferences.getString('uuid') == null) {
//       await _sharedPreferences.setString('uuid', const Uuid().v4());
//     }
//   }
// }

enum Settings<T extends Object?> {
  uuid<String?>("uuid");

  static late SharedPreferences _sharedPreferences;

  final String _key;

  const Settings(this._key);

  T get value => _sharedPreferences.get(_key) as T;

  Future save(T value) async {
    if (value == null) {
      await _sharedPreferences.remove(_key);
    } else {
      if (value is String?) {
        await _sharedPreferences.setString(_key, value as String);
      }
    }
  }

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (uuid.value == null) {
      await uuid.save(const Uuid().v4());
    }
  }
}
