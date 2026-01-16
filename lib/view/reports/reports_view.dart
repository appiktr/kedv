import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/router.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/model/report_model.dart';
import 'package:kedv/service/evaluation_service.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => ReportsViewState();
}

class ReportsViewState extends State<ReportsView> {
  final EvaluationService _evaluationService = EvaluationService();
  late Future<List<ReportModel>> _reportsFuture;

  // Filter & Sort State
  String _selectedFilter = 'Tümü';
  bool _sortAscending = true;

  final List<String> _filters = ['Tümü', 'Mahalleni Değerlendir Raporu', 'Mahallemi Planlıyorum', 'Bir Sorun Bildir'];

  @override
  void initState() {
    super.initState();
    _reportsFuture = _evaluationService.getReports();
  }

  Future<void> loadReports() async {
    setState(() {
      _reportsFuture = _evaluationService.getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Geçmiş Raporlar', style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214))),
        actions: [
          // Sort button
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            tooltip: _sortAscending ? 'Eskiden Yeniye' : 'Yeniden Eskiye',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[300]!),
                );
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadReports,
              color: AppColors.primary,
              child: FutureBuilder<List<ReportModel>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Raporlar yüklenirken bir hata oluştu.\nLütfen daha sonra tekrar deneyin.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body.copyWith(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState())],
                    );
                  }

                  // Filter and Sort Data
                  var reports = snapshot.data!;

                  // Filter
                  if (_selectedFilter != 'Tümü') {
                    reports = reports.where((r) => r.title == _selectedFilter).toList();
                  }

                  // Sort (Date based)
                  reports.sort((a, b) {
                    if (_sortAscending) {
                      return a.completedDate.compareTo(b.completedDate);
                    } else {
                      return b.completedDate.compareTo(a.completedDate);
                    }
                  });

                  if (reports.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(child: Text("Filtreye uygun kayıt bulunamadı.")),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportItem(context, report);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.hint),
          const SizedBox(height: 16),
          Text('Henüz rapor yok', style: AppTextStyles.subtitle),
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
      onTap: () async {
        final result = await context.push('${AppRoutes.reportDetail}/${report.id}', extra: report);
        if (result == true) {
          loadReports();
        }
      },
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
              decoration: BoxDecoration(color: const Color(0xFFF5F0F2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.description_outlined, color: Color(0xFF171214), size: 24),
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
                    '${report.formattedDateLong} tarihinde gönderildi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold, // Bolder
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            const Icon(Icons.chevron_right, color: AppColors.hint),
          ],
        ),
      ),
    );
  }
}
