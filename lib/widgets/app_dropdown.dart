import 'package:flutter/material.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.label,
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.inputText,
          icon: const Icon(
            Icons.unfold_more,
            color: AppColors.hint,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.inputHint,
          ),
          dropdownColor: AppColors.white,
        ),
      ],
    );
  }
}

