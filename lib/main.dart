import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/storage_service.dart';
import 'src/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Premium & Token services
  await initRevenueCat();

  runApp(const CafeAIApp());
}

class CafeAIApp extends StatelessWidget {
  const CafeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<StorageService>(create: (_) => StorageService())],
      child: MaterialApp(
        title: 'Cafe AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
