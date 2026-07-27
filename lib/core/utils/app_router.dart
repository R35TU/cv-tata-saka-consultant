import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/dashboard_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/notifications/presentation/notification_center_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';

class RouterListenable extends ChangeNotifier {
  final Ref _ref;

  RouterListenable(this._ref) {
    _ref.listen<AsyncValue<dynamic>>(
      authControllerProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      // While authentication state is loading, wait and don't redirect
      if (authState.isLoading) {
        return null;
      }

      if (!isLoggedIn) {
        // Guard protected routes by redirecting to /login
        if (!isSplash && !isLogin) {
          return '/login';
        }
      } else {
        // If logged in, prevent accessing login and splash pages
        if (isSplash || isLogin) {
          return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
    ],
  );
});
