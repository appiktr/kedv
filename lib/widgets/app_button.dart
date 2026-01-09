import 'package:flutter/material.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final OutlinedBorder? shape;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text, style: textStyle ?? AppTextStyles.button),
      ),
    );
  }
}
