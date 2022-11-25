import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum Settings<T extends Object?> {
  uuid<String?>('uuid'),
  name<String>('name', 'User');

  static late SharedPreferences _sharedPreferences;

  final String key;
  final T? defaultValue;

  const Settings(
    this.key, [
    this.defaultValue,
  ]);

  T get value {
    final Object? value = _sharedPreferences.get(key);

    if (value == null && defaultValue != null) {
      return defaultValue as T;
    }

    return value as T;
  }

  Future<void> save(final T value) async {
    if (value == null) {
      await _sharedPreferences.remove(key);
    } else {
      if (value.runtimeType is String?) {
        await _sharedPreferences.setString(key, value as String);

        return;
      }

      throw UnsupportedSettingTypeException();
    }
  }

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (uuid.value == null) {
      await uuid.save(const Uuid().v4());
    }
  }
}

class UnsupportedSettingTypeException implements Exception {}
