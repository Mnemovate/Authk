import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authk/auth_service.dart';
import 'package:authk/home_screen.dart';
import 'package:authk/register_screen.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
    this.loadingBuilder,
  });

  final Widget? pageIfNotConnected;
  final Widget Function(BuildContext)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    // Single StreamBuilder is sufficient - no need for ValueListenableBuilder
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading state while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? const _DefaultLoadingScreen();
        }
        
        // User is authenticated, show home page
        if (snapshot.hasData) {
          return const HomePage();
        }
        
        // Not authenticated, show login or register page
        return pageIfNotConnected ?? const RegisterPage();
      },
    );
  }
}

// Extract default loading screen to a separate widget
class _DefaultLoadingScreen extends StatelessWidget {
  const _DefaultLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}