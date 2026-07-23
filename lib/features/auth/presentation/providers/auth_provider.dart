import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: '1',
        name: 'Demo User',
        email: email,
        phone: '0123456789',
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: '1',
        name: name,
        email: email,
        phone: phone,
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});