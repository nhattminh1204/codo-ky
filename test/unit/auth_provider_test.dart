import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthNotifier Google Sign-In Cancellation Tests', () {
    test('AuthState initial values are correct', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isNewUser, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('AuthState copyWith correctly resets error and isLoading on user cancellation', () {
      var state = const AuthState(isLoading: true, error: 'Prior error');
      
      // Simulate user cancellation update with clearError: true
      state = state.copyWith(isLoading: false, clearError: true);

      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('AuthState copyWith maintains unauthenticated status on cancel', () {
      const initialState = AuthState();
      final updatedState = initialState.copyWith(isLoading: false, clearError: true);

      expect(updatedState.isAuthenticated, isFalse);
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.error, isNull);
    });
  });
}
