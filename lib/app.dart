import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/locale_provider.dart';
import 'providers/emergency_provider.dart';
import 'services/search_service.dart';
import 'services/navigation_service.dart';
import 'services/maintenance_service.dart';
import 'models/deceased.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/map_navigation_screen.dart';
import 'screens/deceased_profile_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/report_issue_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/settings_screen_visitor.dart';
import 'screens/settings_profile_screen.dart';
import 'screens/success_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/add_new_screen.dart';
import 'screens/scaffold_with_nav.dart';
import 'theme/app_theme.dart';
import 'welcome_state.dart';

void mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final searchService = SearchService();
  await searchService.setRecords(_demoRecords());
  final maintenanceService = MaintenanceService();
  await maintenanceService.init();
  final navigationService = NavigationService();
  await navigationService.loadPathNetwork();
  final localeProvider = LocaleProvider();
  runApp(SanadCemeteryApp(
    searchService: searchService,
    navigationService: navigationService,
    maintenanceService: maintenanceService,
    localeProvider: localeProvider,
  ));
}

List<Deceased> _demoRecords() {
  return [
    Deceased(
      id: 'grave-001',
      firstName: 'John',
      middleName: 'William',
      lastName: 'Smith',
      birthDate: DateTime(1852, 3, 15),
      deathDate: DateTime(1901, 8, 22),
      isVeteran: true,
      branchOfService: 'Union Army',
      lat: 25.1960,
      lon: 51.4873,
      sectionId: 'A',
      plotNumber: '12',
      bioHtml: '<p>Beloved father and veteran.</p>',
      imageUrls: [],
      familyLinks: [
        FamilyLink(label: 'Spouse', deceasedId: 'grave-002', name: 'Mary Smith'),
      ],
    ),
    Deceased(
      id: 'grave-002',
      firstName: 'Mary',
      lastName: 'Smith',
      birthDate: DateTime(1855, 6, 10),
      deathDate: DateTime(1920, 1, 5),
      lat: 25.1962,
      lon: 51.4875,
      sectionId: 'A',
      plotNumber: '13',
    ),
  ];
}

class SanadCemeteryApp extends StatelessWidget {
  final SearchService searchService;
  final NavigationService navigationService;
  final MaintenanceService maintenanceService;
  final LocaleProvider localeProvider;

  const SanadCemeteryApp({
    super.key,
    required this.searchService,
    required this.navigationService,
    required this.maintenanceService,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<SearchService>.value(value: searchService),
        Provider<NavigationService>.value(value: navigationService),
        ChangeNotifierProvider<MaintenanceService>.value(value: maintenanceService),
        ChangeNotifierProvider<EmergencyProvider>(
          create: (_) => EmergencyProvider()..load(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp.router(
        title: 'Sanad Cemetery',
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.maroon,
            brightness: Brightness.light,
            primary: AppTheme.maroon,
            secondary: AppTheme.maroonSecondary,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleTextStyle: AppTheme.appBarTitle,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shadowColor: Colors.transparent,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              side: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            clipBehavior: Clip.antiAlias,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: const BorderSide(color: AppTheme.maroon, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            height: 64,
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            )),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8E1737),
            brightness: Brightness.dark,
            primary: const Color(0xFF8E1737),
            secondary: const Color(0xFF8E1737),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        routerConfig: _router,
        ),
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/welcome',
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if ((loc == '/' || loc.isEmpty) && !welcomeCompleted) return '/welcome';
    return null;
  },
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/success',
      builder: (_, state) {
        final msg = state.uri.queryParameters['msg'] ?? 'thankYouRequest';
        return SuccessScreen(messageKey: msg, popTo: '/');
      },
    ),
    ShellRoute(
      builder: (context, state, child) =>
          ScaffoldWithNav(child: child, state: state),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/add-new', builder: (_, __) => const AddNewScreen()),
        GoRoute(
          path: '/scan',
          builder: (_, state) => QrScannerScreen(
            forReport: state.uri.queryParameters['forReport'] == '1',
          ),
        ),
        GoRoute(path: '/maintenance', builder: (_, __) => const ReportIssueScreen()),
        GoRoute(path: '/announcements', builder: (_, __) => const AnnouncementsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreenVisitor()),
        GoRoute(path: '/settings/profile', builder: (_, __) => const SettingsProfileScreen()),
        GoRoute(
          path: '/grave/:id',
          builder: (_, state) => DeceasedProfileScreen(graveId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/navigate/:id',
          builder: (_, state) => MapNavigationScreen(graveId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);
