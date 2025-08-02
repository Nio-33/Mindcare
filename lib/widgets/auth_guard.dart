import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/sign_in_screen.dart';
import '../constants/colors.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (kDebugMode) {
          print('AuthGuard: Current state = ${authProvider.state}, user = ${authProvider.user?.uid}');
        }
        
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            if (kDebugMode) {
              print('AuthGuard: Showing loading screen');
            }
            return const _LoadingScreen();
            
          case AuthState.authenticated:
            if (kDebugMode) {
              print('AuthGuard: Showing main app for user ${authProvider.user?.uid}');
            }
            return child;
            
          case AuthState.unauthenticated:
          case AuthState.error:
            if (kDebugMode) {
              print('AuthGuard: Showing sign-in screen, error: ${authProvider.errorMessage}');
            }
            return const SignInScreen();
        }
      },
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Add a timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.state == AuthState.loading || authProvider.state == AuthState.initial) {
          if (kDebugMode) {
            print('AuthGuard: Loading timeout reached, forcing unauthenticated state');
          }
          // Force to show sign-in screen if loading takes too long
          authProvider.clearError(); // This will set state to unauthenticated
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'MindCare',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your wellness journey...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}