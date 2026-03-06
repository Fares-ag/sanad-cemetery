import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/admin_data_provider.dart';
import 'admin_router.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDataProvider()..load(),
      child: MaterialApp.router(
        title: 'Sanad Cemetery Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B7C99),
            brightness: Brightness.light,
            primary: const Color(0xFF5B7C99),
            secondary: const Color(0xFF7A9BB5),
            surface: const Color(0xFFF7F9FB),
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
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF5B7C99).withValues(alpha: 0.06)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            clipBehavior: Clip.antiAlias,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF2F5F8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF5B7C99).withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF5B7C99), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: const Color(0xFF5B7C99).withValues(alpha: 0.12),
            selectedIconTheme: const IconThemeData(color: Color(0xFF5B7C99)),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFF5B7C99),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: const Color(0xFF5B7C99).withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        routerConfig: adminRouter,
      ),
    );
  }
}
