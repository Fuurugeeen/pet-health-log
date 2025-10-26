import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'services/hive_service.dart';
import 'services/sample_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hiveの初期化
  await HiveService.initialize();
  
  // 初回起動時にサンプルデータを生成
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  
  if (isFirstLaunch) {
    await SampleDataService.generateInitialSampleData();
    await prefs.setBool('isFirstLaunch', false);
  }
  
  runApp(
    DevicePreview(
      enabled: true, // 常に有効化（リリースビルドでも使用）
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: DevicePreview.locale(context) ?? const Locale('ja', 'JP'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      builder: DevicePreview.appBuilder,
      routerConfig: router,
    );
  }
}