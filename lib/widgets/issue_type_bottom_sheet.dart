import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/issue_type_model.dart';

class IssueTypeBottomSheet extends StatefulWidget {
  final IssueType? selectedIssue;

  const IssueTypeBottomSheet({
    super.key,
    this.selectedIssue,
  });

  static Future<IssueType?> show(
    BuildContext context, {
    IssueType? selectedIssue,
  }) {
    return showModalBottomSheet<IssueType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => IssueTypeBottomSheet(
        selectedIssue: selectedIssue,
      ),
    );
  }

  @override
  State<IssueTypeBottomSheet> createState() => _IssueTypeBottomSheetState();
}

class _IssueTypeBottomSheetState extends State<IssueTypeBottomSheet> {
  final List<IssueType> _issueTypes = IssueType.mockIssueTypes;
  IssueType? _selectedIssue;

  @override
  void initState() {
    super.initState();
    _selectedIssue = widget.selectedIssue;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sorunu Seçin', style: AppTextStyles.pageTitle),
              ),
            ),

            // Liste
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Sorun tipleri
                  ..._issueTypes.map((issue) => _buildIssueItem(issue)),
                ],
              ),
            ),

            // Butonlar
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // İptal
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.inputBackground,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'İptal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tamam
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _selectedIssue != null
                              ? () {
                                  Navigator.pop(context, _selectedIssue);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Tamam',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIssueItem(IssueType issue) {
    final isSelected = _selectedIssue?.id == issue.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIssue = issue;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // İsim
            Expanded(
              child: Text(
                issue.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
              ),
            ),
            // Resim
            if (issue.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  issue.imageUrl!,
                  width: 130,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 130,
                    height: 64,
                    color: AppColors.inputBackground,
                    child: const Icon(Icons.image, color: AppColors.hint),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
