import 'dart:io' show File, Platform;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_logger.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;
  final LocalStorageService _storage;
  late final GoogleSignIn _googleSignIn;

  AuthRepository(this._storage) {
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? dotenv.env['GOOGLE_CLIENT_ID'];
    final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? dotenv.env['GOOGLE_CLIENT_ID'];

    _googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? iosClientId : null,
      serverClientId: serverClientId,
    );
  }

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
    final payload = data['data'] ?? data;
    final requiresEmailVerification = payload['requiresEmailVerification'] == true || data['requiresEmailVerification'] == true;
    final token = payload['accessToken'] ?? payload['token'] ?? data['token'];
    final refreshToken = payload['refreshToken'] ?? data['refreshToken'];
    final user = payload['user'] ?? data['user'] ?? {};

    if (token != null && !requiresEmailVerification) {
      await _storage.saveUser(
        name: user['name'] ?? '',
        email: user['email'] ?? email,
        token: token.toString(),
        refreshToken: refreshToken?.toString(),
        userId: user['_id']?.toString(),
      );
    }

    return {
      'token': token,
      'requiresEmailVerification': requiresEmailVerification,
      'email': email,
      'user': user,
      'message': data['message'] ?? payload['message'] ?? 'Login successful',
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
    final payload = data['data'] ?? data;
    final requiresEmailVerification = payload['requiresEmailVerification'] == true || data['requiresEmailVerification'] == true;
    final token = payload['accessToken'] ?? payload['token'] ?? data['token'];
    final user = payload['user'] ?? data['user'] ?? {};

    if (token != null && !requiresEmailVerification) {
      await _storage.saveUser(
        name: user['name'] ?? name,
        email: user['email'] ?? email,
        token: token.toString(),
        userId: user['_id']?.toString(),
      );
    }

    return {
      'token': token,
      'requiresEmailVerification': requiresEmailVerification || token == null,
      'email': email,
      'user': user,
      'message': data['message'] ?? 'Registration successful',
    };
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _api.post(
      ApiEndpoints.verifyEmail,
      data: {
        'email': email,
        'code': code,
      },
    );

    final data = response.data;
    final payload = data['data'] ?? data;
    final token = payload['accessToken'] ?? payload['token'] ?? data['token'];
    final refreshToken = payload['refreshToken'] ?? data['refreshToken'];
    final user = payload['user'] ?? data['user'] ?? {};

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? '',
        email: user['email'] ?? email,
        token: token.toString(),
        refreshToken: refreshToken?.toString(),
        userId: user['_id']?.toString(),
        avatar: user['avatar']?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
      'message': data['message'] ?? 'Email verified successfully',
    };
  }

  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    final response = await _api.post(
      ApiEndpoints.resendVerification,
      data: {
        'email': email,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? data : {'message': 'Verification code sent successfully'};
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await _api.post(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? data : {'message': 'Password reset link sent successfully'};
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'password': password,
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> ? data : {'message': 'Password reset successfully'};
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
    final token = data['token'] ?? data['data']?['token'] ?? data['data']?['accessToken'];
    final refreshToken = data['refreshToken'] ?? data['data']?['refreshToken'];
    final user = data['user'] ?? data['data']?['user'] ?? {};
    final avatar = user['avatar'] ?? data['data']?['avatar'];

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? '',
        email: user['email'] ?? email,
        token: token.toString(),
        refreshToken: refreshToken?.toString(),
        userId: user['_id']?.toString(),
        avatar: avatar?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
    };
  }

  Future<AuthorizationCredentialAppleID?> signInWithAppleAccount() async {
    try {
      return await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'cloud.eka-dev.apple-store.service',
          redirectUri: Uri.parse(
            'https://be-apple-store.eka-dev.cloud/api/auth/callback/apple',
          ),
        ),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled ||
          e.message.toLowerCase().contains('canceled') ||
          e.message.toLowerCase().contains('cancelled') ||
          e.message.contains('1001') ||
          e.toString().contains('1001')) {
        AppLogger.i('Apple Sign-In was cancelled by user');
        return null;
      }
      AppLogger.e('Apple Sign-In authorization error: ${e.code} - ${e.message}', e);
      rethrow;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('canceled') || msg.contains('cancelled') || msg.contains('1001')) {
        AppLogger.i('Apple Sign-In was cancelled by user');
        return null;
      }
      AppLogger.e('Apple Sign-In failed', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithAppleApi({
    required String identityToken,
    String? email,
    String? name,
  }) async {
    final response = await _api.post(
      ApiEndpoints.appleAuth,
      data: {
        'identityToken': identityToken,
        if (email != null && email.isNotEmpty) 'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    final data = response.data;
    final token = data['token'] ?? data['data']?['token'] ?? data['data']?['accessToken'];
    final refreshToken = data['refreshToken'] ?? data['data']?['refreshToken'];
    final user = data['user'] ?? data['data']?['user'] ?? {};
    final avatar = user['avatar'] ?? data['data']?['avatar'];

    if (token != null) {
      await _storage.saveUser(
        name: user['name'] ?? name ?? 'Apple User',
        email: user['email'] ?? email ?? '',
        token: token.toString(),
        refreshToken: refreshToken?.toString(),
        userId: user['_id']?.toString(),
        avatar: avatar?.toString(),
      );
    }

    return {
      'token': token,
      'user': user,
    };
  }

  Future<Map<String, dynamic>> getLinkedAccounts() async {
    final response = await _api.get(ApiEndpoints.linkedAccounts);
    final data = response.data?['data'] ?? response.data;
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<Map<String, dynamic>> linkGoogleApi({required String credential, String? email}) async {
    final response = await _api.post(
      ApiEndpoints.linkGoogle,
      data: {
        'credential': credential,
        if (email != null) 'email': email,
      },
    );
    final data = response.data?['data'] ?? response.data;
    if (data?['token'] != null) {
      await _storage.setToken(data['token'].toString());
    }
    if (data?['email'] != null) {
      await _storage.saveUser(
        name: data['name'] ?? _storage.name ?? '',
        email: data['email'].toString(),
      );
    }
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<Map<String, dynamic>> linkAppleApi({required String identityToken, String? email}) async {
    final response = await _api.post(
      ApiEndpoints.linkApple,
      data: {
        'identityToken': identityToken,
        if (email != null) 'email': email,
      },
    );
    final data = response.data?['data'] ?? response.data;
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<Map<String, dynamic>> unbindAppleApi() async {
    final response = await _api.post(ApiEndpoints.unbindApple);
    final data = response.data?['data'] ?? response.data;
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<Map<String, dynamic>> updateProfileName(String name) async {
    final response = await _api.put(
      ApiEndpoints.updateProfile,
      data: {'name': name},
    );
    await _storage.setName(name);
    final data = response.data?['data'] ?? response.data;
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _api.post(
      ApiEndpoints.uploadAvatar,
      data: formData,
    );

    final avatarUrl = response.data?['data']?['avatar'] ?? response.data?['avatar'];
    if (avatarUrl != null) {
      await _storage.setAvatar(avatarUrl.toString());
    }
    return avatarUrl?.toString();
  }

  Future<void> logout() async {
    try {
      final currentRefreshToken = _storage.refreshToken;
      await _api.post(
        ApiEndpoints.logout,
        data: currentRefreshToken != null ? {'refreshToken': currentRefreshToken} : null,
      );
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
