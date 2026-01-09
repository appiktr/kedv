import 'package:flutter/material.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_theme.dart';
import 'package:kedv/helper/dio_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dirençli Mahalle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
