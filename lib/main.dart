import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/app_router.dart';

void main() {
  // Ensure status bar style matches design (e.g. white background on top, dark text)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Tata Saka Consultant',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF001AFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF001AFF),
          primary: const Color(0xFF001AFF),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
      ),
    );
  }
}