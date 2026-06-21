import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/property_details_page.dart';
import '../../features/property/presentation/pages/list_property_page.dart';
import '../../features/property/presentation/pages/category_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';

/// Route name constants
class AppRoutes {
  static const splash        = '/';
  static const welcome       = '/welcome';
  static const login         = '/login';
  static const register      = '/register';
  static const forgotPassword = '/forgot-password';
  static const home          = '/home';
  static const propertyList  = '/properties';
  static const propertyDetail = '/properties/:id';
  static const booking       = '/bookings';
  static const bookingDetail = '/bookings/:id';
  static const payment       = '/payment';
  static const chat          = '/chat';
  static const chatRoom      = '/chat/:roomId';
  static const profile       = '/profile';
  static const notifications = '/notifications';
  static const mapSearch     = '/map-search';
  static const listProperty  = '/list-property';
  static const category      = '/category/:categoryName';
  static const admin         = '/admin';
}

/// Riverpod provider for GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state to redirect unauthenticated users
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Add auth redirect logic here:
      // final isLoggedIn = authState.valueOrNull != null;
      // final isAuthRoute = state.matchedLocation == AppRoutes.login;
      // if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      // if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => WelcomePage(nextRoute: state.uri.queryParameters['next']),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginPage(nextRoute: state.uri.queryParameters['next']),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => RegisterPage(nextRoute: state.uri.queryParameters['next']),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.listProperty,
        builder: (context, state) => const ListPropertyPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'properties',
            builder: (context, state) => const _PlaceholderPage(title: 'Properties'),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final data = state.extra as Map<String, dynamic>? ?? {};
                  return PropertyDetailsPage(propertyData: data);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const _PlaceholderPage(title: 'Chat'),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (context, state) =>
                _PlaceholderPage(title: 'Room ${state.pathParameters['roomId']}'),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.category,
        builder: (context, state) {
          final categoryName = state.pathParameters['categoryName'] ?? 'Unknown';
          final decodedCategory = categoryName.replaceAll('-', ' ');
          return CategoryPage(categoryName: decodedCategory);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const _PlaceholderPage(title: 'Notifications'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// ── Placeholder Pages (replace with actual feature pages) ─────────────────────

// The SplashPage has been moved to lib/features/splash/presentation/pages/splash_page.dart

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)));
}
