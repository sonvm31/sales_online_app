import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_online_app/core/theme/app_theme.dart';
import 'package:sales_online_app/core/theme/theme_provider.dart';
import 'package:sales_online_app/ui/shared/main_wrapper_screen.dart';

final ThemeProvider themeProvider = ThemeProvider();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: themeProvider,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Sales Online System',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.dartTheme,
              themeMode: themeProvider.currentTheme,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
