import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../models/deceased.dart';
import '../models/search_params.dart';
import '../services/search_service.dart';
import '../theme/app_theme.dart';

/// Search for Deceased — aligned to home page design: light theme, maroon accent, same typography.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  SearchParams _params = const SearchParams();
  List<Deceased> _results = [];
  bool _veteranOnly = false;
  String? _branch;

  static const _maroon = Color(0xFF8E1737);

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() {
    final service = context.read<SearchService>();
    setState(() {
      _results = service.search(
        _query.text.trim().isEmpty ? null : _query.text.trim(),
        _params.copyWith(
          isVeteran: _veteranOnly ? true : null,
          branchOfService: _branch?.isEmpty ?? true ? null : _branch,
        ),
      );
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: _maroon, brightness: Brightness.light),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _maroon, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            AppStrings.tr(context, 'searchForDeceased'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(AppIcons.add, size: 26, color: Colors.black87),
              onPressed: () => context.push('/add-new'),
              tooltip: AppStrings.tr(context, 'addNew'),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.tr(context, 'search'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _query,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: AppStrings.tr(context, 'searchByPlaceholder'),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _search,
                    style: FilledButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppStrings.tr(context, 'search'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (_params.hasAnyFilter || _veteranOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_params.birthYearFrom != null || _params.birthYearTo != null)
                      Chip(
                        label: Text('${AppStrings.tr(context, 'birth')} ${_params.birthYearFrom ?? '?'}–${_params.birthYearTo ?? '?'}'),
                        onDeleted: () => setState(() { _params = _params.copyWith(birthYearFrom: null, birthYearTo: null); _search(); }),
                      ),
                    if (_params.deathYearFrom != null || _params.deathYearTo != null)
                      Chip(
                        label: Text('${AppStrings.tr(context, 'death')} ${_params.deathYearFrom ?? '?'}–${_params.deathYearTo ?? '?'}'),
                        onDeleted: () => setState(() { _params = _params.copyWith(deathYearFrom: null, deathYearTo: null); _search(); }),
                      ),
                    if (_veteranOnly)
                      Chip(
                        label: Text(AppStrings.tr(context, 'veteran')),
                        onDeleted: () => setState(() { _veteranOnly = false; _search(); }),
                      ),
                  ],
                ),
              ),
            if (_results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  AppStrings.tr(context, 'recent'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppStrings.tr(context, 'noResults'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.tr(context, 'noResultsSub'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.5),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final d = _results[i];
                        final age = d.birthDate != null && (d.deathYear != null || d.deathDate != null)
                            ? (d.deathYear ?? d.deathDate!.year) - d.birthDate!.year
                            : null;
                        final graveNum = d.plotNumber ?? d.sectionId ?? d.id.replaceAll('grave-', '');
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => context.push('/grave/${d.id}'),
                                onLongPress: () => context.push('/navigate/${d.id}'),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          AppIcons.place,
                                          size: 22,
                                          color: Colors.black.withOpacity(0.45),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${AppStrings.tr(context, 'graveNumber')}: $graveNum',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (age != null)
                                        Text(
                                          '${AppStrings.tr(context, 'age')}: $age',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (i < _results.length - 1)
                              Divider(height: 1, color: Colors.black.withOpacity(0.12)),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
