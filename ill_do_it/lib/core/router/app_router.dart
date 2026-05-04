import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/services/presentation/screens/create_service_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';

/// Navigation path constants
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String services = '/services';
  static const String createService = '/create-service';
  static const String jobs = '/jobs';
  static const String createJob = '/create-job';
  static const String profile = '/profile';
  static const String wallet = '/wallet';
  static const String chat = '/chat';
}

/// GoRouter provider for navigation
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isSigningUp = state.matchedLocation == AppRoutes.signup;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isLoading) return null;

      if (!isAuthenticated) {
        if (isLoggingIn || isSigningUp || isSplash) return null;
        return AppRoutes.login;
      }

      if (isAuthenticated && (isLoggingIn || isSigningUp || isSplash)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.explore,
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.createService,
        builder: (context, state) => const CreateServiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobs,
        builder: (context, state) => const JobsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createJob,
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
    ],
  );
});
