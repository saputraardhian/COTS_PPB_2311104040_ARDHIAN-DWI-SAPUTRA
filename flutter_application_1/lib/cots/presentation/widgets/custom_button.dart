import 'package:flutter/material.dart';
import '../../design_system/styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.surface : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.text : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: AppTextStyles.button.copyWith(
          color: isSecondary ? AppColors.text : Colors.white
        )),
      ),
    );
  }
}