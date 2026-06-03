import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class HomeScreen extends StatefulWidget{

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      appBar: AppBar(
        title: const Text,
      ),
    )
  }
}


