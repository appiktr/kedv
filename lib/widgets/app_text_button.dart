import 'package:flutter/material.dart';
import 'package:kedv/core/theme/app_text_styles.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final AlignmentGeometry? alignment;

  const AppTextButton({
    super.key,
    required this.text,
    this.onTap,
    this.textStyle,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: textStyle ?? AppTextStyles.link,
      ),
    );

    if (alignment != null) {
      return Align(
        alignment: alignment!,
        child: button,
      );
    }

    return button;
  }
}

