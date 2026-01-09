import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:kedv/core/theme/app_colors.dart';
import 'package:kedv/core/theme/app_text_styles.dart';
import 'package:kedv/helper/location_helper.dart';
import 'package:kedv/model/issue_type_model.dart';
import 'package:kedv/widgets/app_button.dart';
import 'package:kedv/widgets/issue_type_bottom_sheet.dart';

class ReportIssueView extends StatefulWidget {
  const ReportIssueView({super.key});

  @override
  State<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<ReportIssueView> {
  final MapController _mapController = MapController();
  final TextEditingController _commentController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  IssueType? _selectedIssue;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Konum servisini kontrol et
    bool serviceEnabled = await LocationHelper.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Konum servisi kapalı. Lütfen GPS\'i açın.';
      });
      return;
    }

    // İzin kontrolü
    final permission = await LocationHelper.checkAndRequestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _errorMessage = LocationHelper.getPermissionStatusMessage(permission);
      });
      return;
    }

    // Konumu al
    final location = await LocationHelper.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
        _selectedLocation = location;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Konum alınamadı. Lütfen tekrar deneyin.';
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  Future<void> _openIssueSelector() async {
    final result = await IssueTypeBottomSheet.show(
      context,
      selectedIssue: _selectedIssue,
    );

    if (result != null) {
      setState(() {
        _selectedIssue = result;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen haritada bir konum seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir sorun tipi seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: API'ye gönder
    // final data = {
    //   'latitude': _selectedLocation!.latitude,
    //   'longitude': _selectedLocation!.longitude,
    //   'issueTypeId': _selectedIssue!.id,
    //   'comment': _commentController.text,
    // };

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorun bildirimi başarıyla gönderildi!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Sorun Bildir',
          style: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFF171214)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Açıklama
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Haritada bir konum seçin ve sorunu seçin.',
                style: AppTextStyles.body.copyWith(color: const Color(0xFF171214)),
              ),
            ),

            // Harita
            SizedBox(
              height: 300,
              child: _buildMap(),
            ),

            // Sorunu Seçin başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Sorunu Seçin',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF171214),
                ),
              ),
            ),

            // Sorun seçici
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: _openIssueSelector,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedIssue?.name ?? 'Bir sorun seçin',
                          style: AppTextStyles.body.copyWith(
                            color: _selectedIssue != null
                                ? const Color(0xFF171214)
                                : AppColors.hint,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.unfold_more,
                        color: Color(0xFF8A6175),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Yorum alanı
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: AppTextStyles.inputText,
                  decoration: InputDecoration(
                    hintText: 'İsteğe bağlı yorumlar',
                    hintStyle: AppTextStyles.inputHint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            // Gönder butonu
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: 'Gönder',
                isLoading: _isSubmitting,
                onTap: _onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return Container(
        color: AppColors.inputBackground,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Konum alınıyor...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: AppColors.inputBackground,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // İstanbul varsayılan konum
    final center = _selectedLocation ?? _currentLocation ?? const LatLng(41.0082, 28.9784);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
        onTap: _onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.kedv',
        ),
        MarkerLayer(
          markers: [
            // Seçili konum marker'ı
            if (_selectedLocation != null)
              Marker(
                point: _selectedLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            // Kullanıcı konumu (farklı renk)
            if (_currentLocation != null && _selectedLocation != _currentLocation)
              Marker(
                point: _currentLocation!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
