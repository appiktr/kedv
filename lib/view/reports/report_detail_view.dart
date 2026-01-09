import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/report_model.dart';

class ReportDetailView extends StatelessWidget {
  final int reportId;

  const ReportDetailView({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    // Mock data'dan raporu bul
    final report = ReportModel.mockReports.firstWhere(
      (r) => r.id == reportId,
      orElse: () => ReportModel.mockReports.first,
    );

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Bakış Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Değerlendirmeye Genel Bakış',
                style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214)),
              ),
            ),

            // Durum
            _buildInfoRow('Değerlendirme Durumu', report.status, report.status),

            // Tarih
            _buildInfoRow('Tamamlanma Tarihi', report.formattedDate, report.formattedDateLong),

            // Tür
            _buildInfoRow('Değerlendirme Türü', report.type, report.type),

            // Sorular Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Değerlendirme Soruları ve Cevapları',
                style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214)),
              ),
            ),

            // Sorular
            ...report.questions.map((q) => _buildQuestionItem(q)),

            // Yorumlar Başlık
            if (report.comments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Yorumlar',
                  style: AppTextStyles.pageTitle.copyWith(color: const Color(0xFF171214)),
                ),
              ),

              // Yorumlar
              ...report.comments.map((c) => _buildCommentItem(c)),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String subtitle, String value) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF171214),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF171214),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(ReportQuestion question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${question.number}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF171214),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.answer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          if (question.comment != null) ...[
            const SizedBox(height: 4),
            Text(
              question.comment!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.hint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.authorImage != null
                ? NetworkImage(comment.authorImage!)
                : null,
            backgroundColor: AppColors.inputBackground,
            child: comment.authorImage == null
                ? const Icon(Icons.person, color: AppColors.hint)
                : null,
          ),
          const SizedBox(width: 12),
          // İçerik
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

