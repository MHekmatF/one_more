// main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:one_more/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard/accountant_dashboard.dart';
import 'services/member_service.dart'; // We'll create this later

// Replace with your Supabase URL and Anon Key
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: "https://imipdagmqgcbsmdnpbma.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImltaXBkYWdtcWdjYnNtZG5wYm1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MDEyODIsImV4cCI6MjA3NTM3NzI4Mn0.MqsAWivf31oK0Q1pjdY31JYCrOeXEaiyfM_Pw1mAPmw",
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MemberService(context), // Pass context here
          lazy: false, // Ensure it's created immediately for context to be available
        ),        // Add other services/providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage( // Use CustomTransitionPage
        key: state.pageKey,
        child: Supabase.instance.client.auth.currentSession == null
            ? const LoginScreen()
            : const AccountantDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade animation for page transitions
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    GoRoute(
      path: '/login',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage( // Apply transition to login
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage( // Apply transition to dashboard
          key: state.pageKey,
          child: const AccountantDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = Supabase.instance.client.auth.currentSession != null;
    final bool loggingIn = state.uri.path == '/login';

    // If not logged in and not on the login page, redirect to login
    if (!loggedIn && !loggingIn) {
      return '/login';
    }
    // If logged in and on the login page, redirect to dashboard
    if (loggedIn && loggingIn) {
      return '/dashboard';
    }
    // No redirect needed
    return null;
  },
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
);

// Helper for GoRouter to listen to auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Club Accountant',
      theme: appTheme(context), // Use your custom theme here
      debugShowCheckedModeBanner: false, // Good for production builds

      routerConfig: _router,
    );
  }
}