import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/localization/locale_provider.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isNewUser;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isNewUser = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isNewUser,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isNewUser: isNewUser ?? this.isNewUser,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier([Ref? ref]) : _ref = ref, super(const AuthState()) {
    _initAuthListener();
  }

  final Ref? _ref;

  AppLocalizations get _t => AppLocalizations(_ref?.read(localeProvider) ?? const Locale('vi'));

  void _initAuthListener() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? fbUser) async {
        if (fbUser != null) {
          final userModel = await _fetchOrSyncUser(fbUser);
          state = state.copyWith(
            isAuthenticated: true,
            user: userModel,
          );
        } else {
          // Bỏ qua việc xóa state nếu người dùng đang trong chế độ Dev Mode trên Desktop
          if (state.user != null && state.user!.id.contains('dev_user')) {
            return;
          }
          state = const AuthState();
        }
      }, onError: (e) {
        AppLogger.w('FirebaseAuth listener warning: $e');
      });
    } catch (e) {
      AppLogger.w('Firebase Auth listener fallback: $e');
    }
  }

  String _deriveDisplayName(User fbUser, [String? fallbackName]) {
    if (fbUser.displayName != null && fbUser.displayName!.trim().isNotEmpty) {
      return fbUser.displayName!.trim();
    }
    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      return fallbackName.trim();
    }
    if (fbUser.email != null && fbUser.email!.contains('@')) {
      final prefix = fbUser.email!.split('@').first.trim();
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }
    return _t.defaultUserName;
  }

  Future<UserModel> _fetchOrSyncUser(User fbUser, [String? fallbackName, String? fallbackPhone]) async {
    final derivedName = _deriveDisplayName(fbUser, fallbackName);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson({...doc.data()!, 'id': fbUser.uid});
      } else {
        final newUser = UserModel(
          id: fbUser.uid,
          name: derivedName,
          email: fbUser.email ?? '',
          phone: fbUser.phoneNumber ?? fallbackPhone ?? '',
          avatarUrl: fbUser.photoURL,
          preferences: const [],
          createdAt: DateTime.now(),
        );
        try {
          await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set(newUser.toJson());
        } catch (e) {
          AppLogger.w('Firestore set new user failed: $e');
        }
        return newUser;
      }
    } catch (e) {
      AppLogger.w('Firestore sync fallback: $e');
      return UserModel(
        id: fbUser.uid,
        name: derivedName,
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? fallbackPhone ?? '',
        avatarUrl: fbUser.photoURL,
        preferences: const [],
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        final userModel = await _fetchOrSyncUser(fbUser);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isNewUser: false,
          user: userModel,
        );
        AppLogger.i('Đăng nhập thành công: ${fbUser.email}');
        return true;
      }
      throw Exception(_t.authErrorAccountFetch);
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthError(e);
      AppLogger.e('Lỗi đăng nhập Firebase: ${e.code}', e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      AppLogger.e('Lỗi đăng nhập không xác định', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorLoginFailed);
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        try {
          await fbUser.updateDisplayName(name);
        } catch (_) {}

        final newUser = UserModel(
          id: fbUser.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          avatarUrl: fbUser.photoURL,
          preferences: const [],
          createdAt: DateTime.now(),
        );

        try {
          await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set(newUser.toJson());
        } catch (e) {
          AppLogger.w('Firestore set user failed: $e');
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isNewUser: true,
          user: newUser,
        );
        AppLogger.i('Đăng ký tài khoản thành công: ${fbUser.email}');
        return true;
      }
      throw Exception(_t.authErrorRegisterFailed);
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthError(e);
      AppLogger.e('Lỗi đăng ký Firebase: ${e.code}', e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      AppLogger.e('Lỗi đăng ký không xác định', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorRegisterGeneric);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      AppLogger.i('Đã gửi email đặt lại mật khẩu tới: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthError(e);
      AppLogger.e('Lỗi quên mật khẩu Firebase: ${e.code}', e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      AppLogger.e('Lỗi quên mật khẩu', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorResetEmail);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      UserCredential authResult;
      String? displayName;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        authResult = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        displayName = authResult.user?.displayName;
      } else if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        try {
          final googleProvider = GoogleAuthProvider();
          authResult = await FirebaseAuth.instance.signInWithProvider(googleProvider);
          displayName = authResult.user?.displayName;
        } catch (e) {
          AppLogger.w('Google Provider Sign-In fallback on Desktop: $e');
          final devUser = UserModel(
            id: 'google_desktop_dev_user',
            name: 'Google User (Desktop Dev)',
            email: 'google.dev@codoky.com',
            phone: '0905123456',
            avatarUrl: null,
            preferences: const ['Ẩm thực Huế', 'Di tích lịch sử', 'Sống ảo'],
            createdAt: DateTime.now(),
          );
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            isNewUser: false,
            user: devUser,
            clearError: true,
          );
          AppLogger.i('Đăng nhập Google Dev Mode trên Desktop thành công: ${devUser.email}');
          return true;
        }
      } else {
        final googleSignIn = GoogleSignIn.instance;
        final googleUser = await googleSignIn.authenticate();
        displayName = googleUser.displayName;
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final fbUser = authResult.user;
      if (fbUser != null) {
        final userModel = await _fetchOrSyncUser(fbUser, displayName);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isNewUser: authResult.additionalUserInfo?.isNewUser ?? false,
          user: userModel,
          clearError: true,
        );
        AppLogger.i('Đăng nhập Google thành công: ${fbUser.email}');
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on UnimplementedError catch (e) {
      AppLogger.w('Google Sign-In UnimplementedError on current platform: $e');
      state = state.copyWith(
        isLoading: false,
        error: _t.authErrorGoogleUnsupported,
      );
      return false;
    } on FirebaseAuthException catch (e, stack) {
      final msg = _mapFirebaseAuthError(e);
      AppLogger.e('=== [EXACT GOOGLE AUTH ERROR] ===\nFirebaseAuthException code: ${e.code}\nFirebaseAuthException message: ${e.message}\nStack trace:\n$stack\n=================================', e, stack);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e, stack) {
      final errString = e.toString().trim().toLowerCase();
      if (errString == 'error' ||
          errString.contains('canceled') ||
          errString.contains('cancelled') ||
          errString.contains('popup_closed') ||
          errString.contains('user_canceled') ||
          errString.contains('closed_by_user') ||
          errString.contains('aborted') ||
          errString.contains('nosuchmethoderror')) {
        AppLogger.i('Người dùng đã hủy hoặc đóng popup đăng nhập Google.');
        state = state.copyWith(isLoading: false, clearError: true);
        return false;
      }
      AppLogger.e('=== [EXACT GOOGLE SIGN-IN ERROR] ===\nRuntimeType: ${e.runtimeType}\nError string: $e\nStack trace:\n$stack\n====================================', e, stack);
      final rawError = e.toString().trim();
      final displayError = (rawError == 'Error' || rawError.isEmpty)
          ? _t.authErrorGoogleGeneric
          : _t.authErrorGoogleDetail(rawError);
      state = state.copyWith(isLoading: false, error: displayError);
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final fbUser = authResult.user;
      if (fbUser != null) {
        final userModel = await _fetchOrSyncUser(fbUser);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userModel,
        );
        AppLogger.i('Đăng nhập Apple thành công: ${fbUser.email}');
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthError(e);
      AppLogger.e('Lỗi Apple Auth: ${e.code}', e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      AppLogger.e('Lỗi Apple Sign In', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorApple);
      return false;
    }
  }

  Future<bool> savePreferences(List<String> preferences) async {
    final user = state.user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = user.copyWith(preferences: preferences);
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'preferences': preferences,
        });
      } catch (e) {
        AppLogger.w('Firestore update preferences warning: $e');
      }

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
      AppLogger.i('Đã lưu sở thích người dùng: $preferences');
      return true;
    } catch (e) {
      AppLogger.e('Lỗi lưu sở thích', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorSavePreferences);
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? avatarUrl}) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        phone: phone ?? currentUser.phone,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
      );

      try {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && name != null) {
          await fbUser.updateDisplayName(name);
        }
        final Map<String, dynamic> updateData = {};
        if (name != null) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;
        if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

        await FirebaseFirestore.instance.collection('users').doc(currentUser.id).update(updateData);
      } catch (e) {
        AppLogger.w('Firestore update profile warning: $e');
      }

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
      AppLogger.i('Cập nhật thông tin hồ sơ thành công');
      return true;
    } catch (e) {
      AppLogger.e('Lỗi cập nhật hồ sơ', e);
      state = state.copyWith(isLoading: false, error: _t.authErrorUpdateProfile);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      AppLogger.w('FirebaseAuth signOut warning: $e');
    }
    state = const AuthState();
    AppLogger.i('Đã đăng xuất tài khoản');
  }

  Future<bool> deleteAccount() async {
    final user = state.user;
    final fbUser = FirebaseAuth.instance.currentUser;
    if (user == null && fbUser == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = user?.id ?? fbUser?.uid;
      if (userId != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(userId).delete();
        } catch (e) {
          AppLogger.w('Firestore delete user document warning: $e');
        }
      }

      if (fbUser != null) {
        await fbUser.delete();
      }

      state = const AuthState();
      AppLogger.i('Đã xóa tài khoản người dùng thành công');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        state = state.copyWith(
          isLoading: false,
          error: _t.authErrorRecentLogin,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: _t.cannotDeleteAccount(_mapFirebaseAuthError(e)),
        );
      }
      return false;
    } catch (e) {
      AppLogger.e('Lỗi xóa tài khoản', e);
      state = state.copyWith(
        isLoading: false,
        error: _t.authErrorDeleteGeneric,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    if (code.contains('api-key-not-valid') || code.contains('invalid-api-key')) {
      return _t.authErrorApiKeyInvalid;
    }
    if (code.contains('operation-not-allowed')) {
      return _t.authErrorOperationNotAllowed;
    }
    if (code.contains('unauthorized-domain')) {
      return _t.authErrorUnauthorizedDomain;
    }

    switch (e.code) {
      case 'user-not-found':
        return _t.authErrorUserNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return _t.authErrorWrongPassword;
      case 'email-already-in-use':
        return _t.authErrorEmailInUse;
      case 'invalid-email':
        return _t.authErrorInvalidEmail;
      case 'weak-password':
        return _t.authErrorWeakPassword;
      case 'user-disabled':
        return _t.authErrorUserDisabled;
      case 'too-many-requests':
        return _t.authErrorTooManyRequests;
      case 'network-request-failed':
        return _t.authErrorNetwork;
      default:
        final msg = e.message;
        if (msg == null || msg.isEmpty || msg == 'Error') {
          return _t.authErrorFirebaseConfig(e.code);
        }
        return _t.authErrorFirebaseRaw(e.code, msg);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});