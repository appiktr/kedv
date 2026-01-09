import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/report_model.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = ReportModel.mockReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Geçmiş Raporlar',
          style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214)),
        ),
      ),
      body: reports.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportItem(context, report);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.hint,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz rapor yok',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Mahalleni değerlendirdiğinde\nraporların burada görünecek.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, ReportModel report) {
    return InkWell(
      onTap: () => context.push('${AppRoutes.reportDetail}/${report.id}'),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            // İkon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF171214),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    report.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF171214),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${report.formattedDate} tarihinde gönderildi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.hint,
            ),
          ],
        ),
      ),
    );
  }
}
