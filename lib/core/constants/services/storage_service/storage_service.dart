import 'dart:async';
import 'dart:developer' as dev;
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/utils/hive_box.dart';

class StorageService with ListenableServiceMixin {
  final HiveInterface _hive = locator<HiveInterface>();

  // --- Hive Boxes ---
  Box<bool>? _boolBox;
  Box<String>? _stringBox;
  Box<int>? _intBox;
  Box<double>? _doubleBox;

  // --- Initialization ---
  Future<void> init() async {
    dev.log('🗄️ INITIALIZING StorageService', name: 'STORAGE');

    if (!(_hive.isBoxOpen(HiveBox.bools))) {
      _boolBox = await _hive.openBox<bool>(HiveBox.bools);
      dev.log('📦 Opened bools box', name: 'STORAGE');
    } else {
      _boolBox = _hive.box<bool>(HiveBox.bools);
    }

    if (!(_hive.isBoxOpen(HiveBox.strings))) {
      _stringBox = await _hive.openBox<String>(HiveBox.strings);
      dev.log('📦 Opened strings box', name: 'STORAGE');
    } else {
      _stringBox = _hive.box<String>(HiveBox.strings);
    }

    if (!(_hive.isBoxOpen(HiveBox.ints))) {
      _intBox = await _hive.openBox<int>(HiveBox.ints);
      dev.log('📦 Opened ints box', name: 'STORAGE');
    } else {
      _intBox = _hive.box<int>(HiveBox.ints);
    }

    if (!(_hive.isBoxOpen(HiveBox.doubles))) {
      _doubleBox = await _hive.openBox<double>(HiveBox.doubles);
      dev.log('📦 Opened doubles box', name: 'STORAGE');
    } else {
      _doubleBox = _hive.box<double>(HiveBox.doubles);
    }

    dev.log('✅ StorageService initialization complete', name: 'STORAGE');
  }

  // ---------------------- STRING ----------------------
  Future<void> addString(String key, String value) async {
    dev.log(
      '💾 SAVING STRING: $key = ${value.length > 50 ? "${value.substring(0, 50)}..." : value}',
      name: 'STORAGE',
    );
    await _stringBox?.put(key, value);
    notifyListeners();
  }

  String? getString(String key, {String defaultValue = ''}) {
    final value = _stringBox?.get(key, defaultValue: defaultValue);
    dev.log(
      '📖 GETTING STRING: $key = ${value != null && value.length > 50 ? "${value.substring(0, 50)}..." : value}',
      name: 'STORAGE',
    );
    return value;
  }

  Future<void> removeString(String key) async {
    dev.log('🗑️ REMOVING STRING: $key', name: 'STORAGE');
    await _stringBox?.delete(key);
    notifyListeners();
  }

  bool containsString(String key) {
    final contains = _stringBox?.containsKey(key) ?? false;
    dev.log('🔍 CHECKING STRING: $key exists = $contains', name: 'STORAGE');
    return contains;
  }

  // ---------------------- BOOL ----------------------
  Future<void> addBool(String key, bool value) async {
    dev.log('💾 SAVING BOOL: $key = $value', name: 'STORAGE');
    await _boolBox?.put(key, value);
    notifyListeners();
  }

  bool? getBool(String key, {bool defaultValue = false}) {
    final value = _boolBox?.get(key, defaultValue: defaultValue);
    dev.log('📖 GETTING BOOL: $key = $value', name: 'STORAGE');
    return value;
  }

  Future<void> removeBool(String key) async {
    dev.log('🗑️ REMOVING BOOL: $key', name: 'STORAGE');
    await _boolBox?.delete(key);
    notifyListeners();
  }

  bool containsBool(String key) {
    final contains = _boolBox?.containsKey(key) ?? false;
    dev.log('🔍 CHECKING BOOL: $key exists = $contains', name: 'STORAGE');
    return contains;
  }

  // ---------------------- INT ----------------------
  Future<void> addInt(String key, int value) async {
    dev.log('💾 SAVING INT: $key = $value', name: 'STORAGE');
    await _intBox?.put(key, value);
    notifyListeners();
  }

  int? getInt(String key, {int defaultValue = 0}) {
    final value = _intBox?.get(key, defaultValue: defaultValue);
    dev.log('📖 GETTING INT: $key = $value', name: 'STORAGE');
    return value;
  }

  Future<void> removeInt(String key) async {
    dev.log('🗑️ REMOVING INT: $key', name: 'STORAGE');
    await _intBox?.delete(key);
    notifyListeners();
  }

  bool containsInt(String key) {
    final contains = _intBox?.containsKey(key) ?? false;
    dev.log('🔍 CHECKING INT: $key exists = $contains', name: 'STORAGE');
    return contains;
  }

  // ---------------------- DOUBLE ----------------------
  Future<void> addDouble(String key, double value) async {
    dev.log('💾 SAVING DOUBLE: $key = $value', name: 'STORAGE');
    await _doubleBox?.put(key, value);
    notifyListeners();
  }

  double? getDouble(String key, {double defaultValue = 0.0}) {
    final value = _doubleBox?.get(key, defaultValue: defaultValue);
    dev.log('📖 GETTING DOUBLE: $key = $value', name: 'STORAGE');
    return value;
  }

  Future<void> removeDouble(String key) async {
    dev.log('🗑️ REMOVING DOUBLE: $key', name: 'STORAGE');
    await _doubleBox?.delete(key);
    notifyListeners();
  }

  bool containsDouble(String key) {
    final contains = _doubleBox?.containsKey(key) ?? false;
    dev.log('🔍 CHECKING DOUBLE: $key exists = $contains', name: 'STORAGE');
    return contains;
  }

  // ---------------------- CLEAR ALL ----------------------
  Future<void> clearAll() async {
    dev.log('🧹 CLEARING ALL storage data', name: 'STORAGE');
    await _boolBox?.clear();
    await _stringBox?.clear();
    await _intBox?.clear();
    await _doubleBox?.clear();
    notifyListeners();
    dev.log('✅ All storage data cleared', name: 'STORAGE');
  }

  /// SAVE TOKEN
  Future<void> saveToken(String token) async {
    dev.log('🔐 SAVING TOKEN', name: 'STORAGE');
    await _stringBox?.put(StorageKeys.token, token);
    notifyListeners();
  }

  /// GET TOKEN
  String? getToken() {
    final token = _stringBox?.get(StorageKeys.token);
    dev.log(
      '🔐 GETTING TOKEN: ${token != null ? "FOUND" : "NULL"}',
      name: 'STORAGE',
    );
    return token;
  }

  /// REMOVE TOKEN (logout)
  Future<void> clearToken() async {
    dev.log('🧹 REMOVING TOKEN', name: 'STORAGE');
    await _stringBox?.delete(StorageKeys.token);
    notifyListeners();
  }
}

class StorageKeys {
  static const String token = "token";
}
