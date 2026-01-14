import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kedv/view/login/login_view.dart';
import 'package:kedv/view/main/main_shell.dart';
import 'package:kedv/view/register/register_view.dart';
import 'package:kedv/view/report_issue/report_issue_view.dart';
import 'package:kedv/view/reports/report_detail_view.dart';
import 'package:kedv/view/splash/splash_view.dart';
import 'package:kedv/view/survey/survey_view.dart';

/// Route isimleri
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String survey = '/survey';
  static const String planning = '/planning-survey';
  static const String reportIssue = '/report-issue';
  static const String reportDetail = '/report-detail';
}

/// Router yapılandırması
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: AppRoutes.splash, name: 'splash', builder: (context, state) => const SplashView()),
    GoRoute(path: AppRoutes.login, name: 'login', builder: (context, state) => const LoginView()),
    GoRoute(path: AppRoutes.register, name: 'register', builder: (context, state) => const RegisterView()),
    GoRoute(path: AppRoutes.home, name: 'home', builder: (context, state) => const MainShell()),
    GoRoute(
      path: AppRoutes.survey,
      name: 'survey',
      builder: (context, state) => const SurveyView(type: SurveyType.evaluation),
    ),
    GoRoute(
      path: AppRoutes.planning,
      name: 'planning',
      builder: (context, state) => const SurveyView(type: SurveyType.planning),
    ),
    GoRoute(path: AppRoutes.reportIssue, name: 'reportIssue', builder: (context, state) => const ReportIssueView()),
    GoRoute(
      path: '${AppRoutes.reportDetail}/:id',
      name: 'reportDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        return ReportDetailView(reportId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Sayfa bulunamadı', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Hata: ${state.error}'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Ana Sayfaya Dön')),
        ],
      ),
    ),
  ),
);
