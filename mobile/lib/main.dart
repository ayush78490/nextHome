
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // ── Hive local storage ───────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.userBox);

  // ── Google Sign-In Initialization ─────────────────────────────────────────
  await GoogleSignIn.instance.initialize(
    // Web application client ID — required so Google issues an ID token for backend verification
    serverClientId: '453210352651-f4b7l1t9pidf73nv0ko5mkk7ddkonpt3.apps.googleusercontent.com',
  );
  // Hive.registerAdapter(UserModelAdapter());

  // ── System UI ────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // Riverpod ProviderScope wraps entire app
    const ProviderScope(child: NextHomeApp()),
  );
}

class NextHomeApp extends ConsumerWidget {
  const NextHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Next Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
