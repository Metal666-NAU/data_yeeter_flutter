import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum Settings<T extends Object?> {
  uuid<String?>('uuid'),
  name<String>(
    'name',
    'User',
  ),
  debugServerAddress<String?>(
    'debugServerAddress',
    'wss://localhost:45666',
  ),
  productionServerAddress<String?>(
    'productionServerAddress',
    'wss://metal666-server.pp.ua:8443',
  );

  static late SharedPreferences _sharedPreferences;

  final String key;
  final T? defaultValue;

  const Settings(
    this.key, [
    this.defaultValue,
  ]);

  T get value {
    final Object? value = _sharedPreferences.get(key);

    if (null is! T && value == null) {
      if (defaultValue == null) {
        throw NoDefaultValueException(key);
      }

      return defaultValue as T;
    }

    return value as T;
  }

  T? get valueOrDefault => value ?? defaultValue;

  Future<void> save(final T? value) async {
    if (value == null) {
      await _sharedPreferences.remove(key);
    } else {
      if (value is String) {
        await _sharedPreferences.setString(key, value);

        return;
      }
      // Other handlers here...
      /*if (value is ...) {


        return;
      }*/

      throw UnsupportedSettingTypeException(key);
    }
  }

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    // ↓ Uncommment to clear all settings ↓
    //await reset(/*[settingA, settingB]*/);

    // Initialization for individual settings
    if (uuid.value == null) {
      await uuid.save(const Uuid().v4());
    }
  }

  static Future<void> reset([final List<Settings> except = const []]) async {
    for (final setting in values) {
      if (except.contains(setting)) {
        continue;
      }

      await setting.save(null);
    }
  }
}

abstract class SettingException implements Exception {
  final String _settingName;

  const SettingException(this._settingName);

  String get message;

  @override
  String toString() => message;
}

class NoDefaultValueException extends SettingException {
  const NoDefaultValueException(final String settingName) : super(settingName);

  @override
  String get message =>
      'Attempted to get a non-nullable setting "$_settingName" wich was not assigned and doesn\'t have a default value.';
}

class UnsupportedSettingTypeException extends SettingException {
  const UnsupportedSettingTypeException(super.settingName);

  @override
  String get message =>
      'Attempted to save setting $_settingName of unsupported type. Try adding a "_sharedPreferences.set*(key, value)" call for your type in the "save" method in Settings enum.';
}
