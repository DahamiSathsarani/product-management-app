import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/product_service.dart';
import 'services/category_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('products'); 

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Env load failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product Manager',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
        },
      ),
    );
  }
}