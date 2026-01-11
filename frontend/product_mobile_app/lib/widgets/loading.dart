import 'package:flutter/material.dart';
import '../app/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: AppColors.yellowColor,
    );
  }
}