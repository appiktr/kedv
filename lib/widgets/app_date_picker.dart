import 'package:flutter/material.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class AppDatePicker extends StatelessWidget {
  final String? label;
  final String hintText;
  final DateTime? value;
  final void Function(DateTime?)? onChanged;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    this.label,
    required this.hintText,
    this.value,
    this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'tr').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[Text(label!, style: AppTextStyles.label), const SizedBox(height: 8)],
        FormField<DateTime>(
          validator: (_) => validator?.call(value),
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: state.hasError ? Border.all(color: AppColors.error) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value != null ? _formatDate(value!) : hintText,
                            style: value != null ? AppTextStyles.inputText : AppTextStyles.inputHint,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AppColors.hint),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Text(state.errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
