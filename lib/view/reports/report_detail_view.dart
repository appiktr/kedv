import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/report_model.dart';
import 'package:kedv/service/evaluation_service.dart';
import 'package:kedv/service/profile_service.dart';
import 'package:kedv/widgets/image_source_sheet.dart';

class ReportDetailView extends StatefulWidget {
  final int reportId;
  final ReportModel? report;

  const ReportDetailView({super.key, required this.reportId, this.report});

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  bool _isEditing = false;
  late ReportModel? _report;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  void _enterEditMode() {
    if (_report == null) return;
    _answers.clear();
    for (var q in _report!.questions) {
      if (q.key != null) {
        // Use rawAnswer if available, otherwise fallback to empty
        // For multi-select, rawAnswer might be a list
        // However, form fields usually expect simple types or we need specific parsing
        // For simplicity, we store exact rawAnswer
        _answers[q.key!] = q.rawAnswer;
      }
    }
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveChanges() async {
    if (_report == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = EvaluationService();
      final profileService = ProfileService();

      // Fetch profile to get profile_id
      final profile = await profileService.getProfile();
      if (profile == null) {
        throw Exception('Profil bilgisi alınamadı. Lütfen tekrar giriş yapın.');
      }

      // Prepare payload
      // Deep copy to modify
      final Map<String, dynamic> payload = Map.from(_answers);

      // Upload images if any, or normalize existing maps to IDs/names
      // We iterate keys to find File objects or Maps
      for (var key in _answers.keys) {
        var value = _answers[key];
        if (value is File) {
          // Upload media returns 'name' string
          final mediaName = await service.uploadMedia(value);
          payload[key] = mediaName; // Replace File with filename string
        } else if (value is Map && value.containsKey('name')) {
          // If it's an existing image map, we send the name
          payload[key] = value['name'];
        } else if (value is Map && value.containsKey('id')) {
          // Fallback if still using ID for some reason, but likely name based on error
          payload[key] = value['id'];
        }
      }

      payload['profile_id'] = profile.id;

      final now = DateTime.now();
      payload['date'] = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      if (_report!.title == 'Mahalleni Değerlendir Raporu') {
        await service.updateNotification(_report!.id, payload);
      } else if (_report!.title == 'Mahallemi Planlıyorum') {
        await service.updateNeighbourhoodEvaluation(_report!.id, payload);
      } else {
        await service.updatePriveNotification(_report!.id, payload);
      }

      // Success
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapor başarıyla güncellendi'), backgroundColor: AppColors.success),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_report == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Rapor Detay'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Rapor yüklenemedi.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF171214)),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Değerlendirme Ayrıntıları',
          style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214)),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: _enterEditMode,
              tooltip: 'Düzenle',
            )
          else ...[
            if (_isLoading)
              const Center(
                child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                tooltip: 'İptal',
              ),
              IconButton(
                icon: const Icon(Icons.check, color: AppColors.success),
                onPressed: _saveChanges,
                tooltip: 'Kaydet',
              ),
            ],
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Bakış
            if (!_isEditing) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Değerlendirmeye Genel Bakış',
                  style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214)),
                ),
              ),
              _buildSummaryCard(_report!),
            ],

            // Sorular Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                _isEditing ? 'Soruları Düzenle' : 'Değerlendirme Soruları ve Cevapları',
                style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214)),
              ),
            ),

            // Sorular
            ..._report!.questions.map((q) => _buildQuestionItem(q)),

            if (!_isEditing && _report!.comments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Yorumlar', style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214))),
              ),
              ..._report!.comments.map((c) => _buildCommentItem(c)),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ReportModel report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSummaryItem(Icons.check_circle_outline, 'Durum', report.status, AppColors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.inputBackground),
          ),
          _buildInfoRow(Icons.calendar_today, 'Tarih', report.formattedDateLong),
          if (report.categoryInfo != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (report.categoryInfo!['category_label'] != null)
              _buildInfoRow(Icons.category, 'Kategori', report.categoryInfo!['category_label']),
            if (report.categoryInfo!['subCategory_label'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.subdirectory_arrow_right, 'Alt Kategori', report.categoryInfo!['subCategory_label']),
            ],
            if (report.categoryInfo!['sub_subCategory_label'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.low_priority, 'Detay', report.categoryInfo!['sub_subCategory_label']),
            ],
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.inputBackground),
          ),
          _buildSummaryItem(Icons.content_paste_go_rounded, 'Tür', report.type, const Color(0xFF171214)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.hint),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return _buildSummaryItem(icon, label, value, const Color(0xFF171214));
  }

  Widget _buildQuestionItem(ReportQuestion question) {
    if (_isEditing && question.key != null) {
      return _buildEditQuestionItem(question);
    }
    return _buildViewQuestionItem(question);
  }

  Widget _buildViewQuestionItem(ReportQuestion question) {
    String answerDisplay = question.answer;

    if (answerDisplay.contains('Diğer')) {
      answerDisplay = answerDisplay.replaceAll('Diğer, ', '').replaceAll(', Diğer', '').replaceAll('Diğer', '').trim();
    }

    if (answerDisplay.isEmpty && (question.comment == null || question.comment!.isEmpty)) {
      answerDisplay = '-';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${question.number}',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.hint),
          ),
          const SizedBox(height: 4),
          Text(
            question.question,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          if (question.type == 'image' && question.answer != '-' && question.answer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  question.answer,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(8)),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (answerDisplay.isNotEmpty && answerDisplay != '-')
                      TextSpan(
                        text: answerDisplay,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (question.comment != null && question.comment!.isNotEmpty) ...[
                      if (answerDisplay.isNotEmpty && answerDisplay != '-') const TextSpan(text: '\n'),
                      TextSpan(
                        text: question.comment,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditQuestionItem(ReportQuestion question) {
    bool hasOptions = question.options != null && question.options!.isNotEmpty;
    var initialValue = _answers[question.key];

    // Determine if we should show checkboxes (Multi-select)
    bool isMultiSelect = initialValue is List;

    // Check for image type
    bool isImage = question.type == 'image';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${question.number}',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.hint),
          ),
          const SizedBox(height: 4),
          Text(
            question.question,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          if (isImage)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (initialValue != null && initialValue != '-' && initialValue.toString().isNotEmpty)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: initialValue is File
                            ? Image.file(initialValue, height: 200, width: double.infinity, fit: BoxFit.cover)
                            : Image.network(
                                (initialValue is Map && initialValue['url'] != null)
                                    ? initialValue['url']
                                    : initialValue.toString(),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            // Removing image means setting it to empty string or null
                            _answers[question.key!] = '';
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red, size: 30),
                        style: IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      final source = await ImageSourceSheet.show(context);
                      if (source != null) {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: source);
                        if (image != null) {
                          setState(() {
                            _answers[question.key!] = File(image.path);
                          });
                        }
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.hint.withOpacity(0.5), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo, size: 40, color: AppColors.hint),
                          const SizedBox(height: 8),
                          Text('Fotoğraf Seç', style: GoogleFonts.plusJakartaSans(color: AppColors.hint)),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          else if (hasOptions)
            if (isMultiSelect)
              Column(
                children: question.options!.map((opt) {
                  final val = opt['value'];
                  final label = opt['label'] ?? val.toString();
                  final List currentList = (initialValue as List);
                  final isChecked = currentList.contains(val);

                  return CheckboxListTile(
                    title: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                    value: isChecked,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          if (!currentList.contains(val)) currentList.add(val);
                        } else {
                          currentList.remove(val);
                        }
                        // Update _answers reference just in case (it's already modified by ref, but good practice)
                        _answers[question.key!] = currentList;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  );
                }).toList(),
              )
            else
              // Single Select Dropdown
              Builder(
                builder: (context) {
                  // Validate initialValue exists in options
                  final containsValue = question.options!.any((opt) => opt['value'] == initialValue);
                  final validValue = containsValue ? initialValue : null;

                  return DropdownButtonFormField<dynamic>(
                    value: validValue,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: question.options!.map((opt) {
                      return DropdownMenuItem(
                        value: opt['value'],
                        child: Text(opt['label'] ?? opt['value'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _answers[question.key!] = val;
                      });
                    },
                  );
                },
              )
          else
            TextFormField(
              initialValue: initialValue?.toString() ?? '',
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                _answers[question.key!] = val;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ReportComment comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.authorImage != null ? NetworkImage(comment.authorImage!) : null,
            backgroundColor: AppColors.inputBackground,
            child: comment.authorImage == null ? const Icon(Icons.person, color: AppColors.hint) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF171214),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      comment.formattedDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF171214),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
