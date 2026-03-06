import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Shell that shows the current page with a bottom navigation bar on every screen.
/// Per Figma: white bar, thin top line, inactive = grey icon + dark label, active = maroon #8E1737 pill with white icon + label.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final GoRouterState state;

  static const _paths = ['/', '/maintenance', '/announcements', '/settings'];
  static const _labelKeys = ['home', 'report', 'announcements', 'settings'];
  static const _icons = [
    AppIcons.home,
    AppIcons.report,
    AppIcons.campaign,
    AppIcons.settings,
  ];
  static const _maroon = Color(0xFF8E1737);

  int _selectedIndex() {
    final path = state.uri.path;
    for (var i = 0; i < _paths.length; i++) {
      if (path == _paths[i] || path.startsWith('${_paths[i]}/')) return i;
    }
    if (path.startsWith('/grave') || path.startsWith('/navigate')) return 0;
    if (path.startsWith('/search')) return 0;
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    context.go(_paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex().clamp(0, _icons.length - 1);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.12), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: List.generate(_icons.length, (i) {
                final isSelected = i == selected;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTabTap(context, i),
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? _maroon : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _icons[i],
                              size: 28,
                              color: isSelected ? Colors.white : Colors.black.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppStrings.tr(context, _labelKeys[i]),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
