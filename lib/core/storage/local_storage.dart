import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyToken = 'token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyUserId = 'user_id';
  static const String _keyAvatar = 'avatar';

  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static LocalStorageService get instance =>
      _instance ?? LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Token methods
  String? get token => _preferences?.getString(_keyToken);
  bool get hasToken => token != null && token!.isNotEmpty;

  Future<bool> setToken(String token) async {
    return await _preferences?.setString(_keyToken, token) ?? false;
  }

  Future<bool> removeToken() async {
    return await _preferences?.remove(_keyToken) ?? false;
  }

  // Refresh Token methods (supports both 'refresh_token' and legacy 'refreshToken')
  String? get refreshToken =>
      _preferences?.getString(_keyRefreshToken) ??
      _preferences?.getString('refreshToken');
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;

  Future<bool> setRefreshToken(String token) async {
    return await _preferences?.setString(_keyRefreshToken, token) ?? false;
  }

  Future<bool> removeRefreshToken() async {
    await _preferences?.remove('refreshToken');
    return await _preferences?.remove(_keyRefreshToken) ?? false;
  }

  // User details
  String? get name => _preferences?.getString(_keyName);
  String? get email => _preferences?.getString(_keyEmail);
  String? get userId => _preferences?.getString(_keyUserId);
  String? get avatar => _preferences?.getString(_keyAvatar);

  Future<bool> setAvatar(String avatarUrl) async {
    return await _preferences?.setString(_keyAvatar, avatarUrl) ?? false;
  }

  Future<bool> setName(String name) async {
    return await _preferences?.setString(_keyName, name) ?? false;
  }

  // Address persistence
  static const String _keySelectedAddressId = 'selected_address_id';
  String? get selectedAddressId =>
      _preferences?.getString(_keySelectedAddressId);
  Future<bool> setSelectedAddressId(String id) async =>
      await _preferences?.setString(_keySelectedAddressId, id) ?? false;

  Future<void> saveUser({
    required String name,
    required String email,
    String? token,
    String? refreshToken,
    String? userId,
    String? avatar,
  }) async {
    if (token != null) await setToken(token);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    await _preferences?.setString(_keyName, name);
    await _preferences?.setString(_keyEmail, email);
    if (userId != null) await _preferences?.setString(_keyUserId, userId);
    if (avatar != null) await _preferences?.setString(_keyAvatar, avatar);
  }

  Future<void> clearAuth() async {
    await _preferences?.remove(_keyToken);
    await _preferences?.remove(_keyRefreshToken);
    await _preferences?.remove('refreshToken');
    await _preferences?.remove(_keyName);
    await _preferences?.remove(_keyEmail);
    await _preferences?.remove(_keyUserId);
    await _preferences?.remove(_keyAvatar);
  }
}
