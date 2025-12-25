import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/sync_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/platform/platform_detector.dart';
import 'core/platform/platform_adapter.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/inspection/presentation/pages/inspection_page.dart';
import 'features/inspection/presentation/pages/defect_record_page.dart';
import 'features/inspection/domain/models/track_point.dart';
import 'features/inspection/domain/models/road_defect.dart';
import 'features/inspection/data/services/background_tracking_service.dart';
import 'features/maintenance/domain/models/maintenance_task.dart';
import 'features/maintenance/presentation/pages/maintenance_page.dart';
import 'features/report/presentation/pages/report_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'shared/widgets/sync_status_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 打印平台信息（调试用）
  PlatformDetector.printInfo();
  PlatformAdapter().printAdapterInfo();
  
  // 初始化Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TrackPointAdapter());
  Hive.registerAdapter(RoadDefectAdapter());
  Hive.registerAdapter(MaintenanceTaskAdapter());
  
  // 打开Boxes
  await Hive.openBox<TrackPoint>('track_points');
  await Hive.openBox<RoadDefect>('defects');
  await Hive.openBox<MaintenanceTask>('tasks');
  
  // 初始化后台服务
  await BackgroundTrackingService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => SyncProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Road Maintenance',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // 国际化配置
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'), // 中文
              Locale('en'), // 英文
            ],
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isAuthenticated 
                    ? const HomePage() 
                    : const LoginPage();
              },
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
              '/inspection': (context) => const InspectionPage(),
              '/defect-record': (context) => const DefectRecordPage(),
              '/maintenance': (context) => const MaintenancePage(),
              '/report': (context) => const ReportPage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uiConfig = PlatformAdapter().getUIConfig();
    final borderRadius = uiConfig['borderRadius'] ?? 8.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.home_title),
            if (PlatformDetector.isHarmonyOS)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HarmonyOS',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          // 同步按钮
          Consumer<SyncProvider>(
            builder: (context, syncProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: syncProvider.isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    onPressed: syncProvider.isSyncing
                        ? null
                        : () => syncProvider.manualSync(),
                  ),
                  if (syncProvider.totalUnsynced > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${syncProvider.totalUnsynced}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusWidget(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.map,
                  title: l10n.home_inspection,
                  subtitle: l10n.home_inspectionSubtitle,
                  color: Colors.blue,
                  borderRadius: borderRadius,
                  onTap: () => Navigator.pushNamed(context, '/inspection'),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.camera_alt,
                  title: l10n.home_defectRecord,
                  subtitle: l10n.home_defectRecordSubtitle,
                  color: Colors.red,
                  borderRadius: borderRadius,
                  onTap: () => Navigator.pushNamed(context, '/defect-record'),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.build,
                  title: l10n.home_maintenance,
                  subtitle: l10n.home_maintenanceSubtitle,
                  color: Colors.green,
                  borderRadius: borderRadius,
                  onTap: () => Navigator.pushNamed(context, '/maintenance'),
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.bar_chart,
                  title: l10n.home_report,
                  subtitle: l10n.home_reportSubtitle,
                  color: Colors.orange,
                  borderRadius: borderRadius,
                  onTap: () => Navigator.pushNamed(context, '/report'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double borderRadius,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
