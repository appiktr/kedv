import 'package:flutter/material.dart';
import 'package:kedv/view/home/home_view.dart';
import 'package:kedv/view/profile/profile_view.dart';
import 'package:kedv/view/reports/reports_view.dart';
import 'package:kedv/widgets/app_bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<ReportsViewState> _reportsKey = GlobalKey<ReportsViewState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const HomeView(), ReportsView(key: _reportsKey), const ProfileView()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1 && _currentIndex != 1) {
            // If switching TO reports tab, reload
            _reportsKey.currentState?.loadReports();
          } else if (index == 1 && _currentIndex == 1) {
            // If tapping reports tab AGAIN, also reload
            _reportsKey.currentState?.loadReports();
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
