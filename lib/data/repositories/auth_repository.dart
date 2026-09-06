import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_logger.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;
  final LocalStorageService _storage;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository(this._storage);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final token = data['token'] ?? data['data']?['token'];
    final user = data['user'] ?? data['data']?['user'] ?? {};

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? '',
        email: user['email'] ?? email,
        token: token.toString(),
        userId: user['_id']?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final token = data['token'] ?? data['data']?['token'];
    final user = data['user'] ?? data['data']?['user'] ?? {};

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? name,
        email: user['email'] ?? email,
        token: token.toString(),
        userId: user['_id']?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
    };
  }

  Future<GoogleSignInAccount?> signInWithGoogleAccount() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      AppLogger.e('Google Sign-In failed', e);
      return null;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogleApi({required String email}) async {
    final response = await _api.post(
      ApiEndpoints.googleLogin,
      data: {'email': email},
    );

    final data = response.data;
    final token = data['token'] ?? data['data']?['token'];
    final user = data['user'] ?? data['data']?['user'] ?? {};

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? '',
        email: user['email'] ?? email,
        token: token.toString(),
        userId: user['_id']?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
    };
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (e) {
      AppLogger.w('Backend logout failed or offline: $e');
    } finally {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _storage.clearAuth();
    }
  }
}
