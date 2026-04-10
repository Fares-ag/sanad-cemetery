import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/app_content.dart';
import '../providers/app_content_provider.dart';
import '../theme/app_theme.dart';

/// Home top hero: image + swipeable lines from municipality [AppContentProvider], with fallbacks.
class HomeHeroCarousel extends StatelessWidget {
  const HomeHeroCarousel({super.key, required this.onReport});

  final VoidCallback onReport;

  static const _fallbackAsset = 'images/home-img.png';

  /// When API has no slides, use these l10n keys (same as legacy hardcoded hero).
  static const List<String> _fallbackSlideKeys = [
    'reportVisibleIssues',
    'searchDiscoverSub',
    'navigateToGraveSub',
    'maintenanceRequestSub',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContentProvider>(
      builder: (context, ac, _) {
        final hero = ac.data?.homeHero;
        return _HomeHeroCarouselBody(
          slidesFromApi: hero?.slides,
          imageUrl: hero?.imageUrl?.trim(),
          reportCtaEn: hero?.reportCtaEn?.trim(),
          reportCtaAr: hero?.reportCtaAr?.trim(),
          onReport: onReport,
        );
      },
    );
  }
}

class _HomeHeroCarouselBody extends StatefulWidget {
  const _HomeHeroCarouselBody({
    required this.slidesFromApi,
    required this.imageUrl,
    required this.reportCtaEn,
    required this.reportCtaAr,
    required this.onReport,
  });

  final List<HomeHeroSlide>? slidesFromApi;
  final String? imageUrl;
  final String? reportCtaEn;
  final String? reportCtaAr;
  final VoidCallback onReport;

  @override
  State<_HomeHeroCarouselBody> createState() => _HomeHeroCarouselBodyState();
}

class _HomeHeroCarouselBodyState extends State<_HomeHeroCarouselBody> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _slideCount(BuildContext context) {
    final api = widget.slidesFromApi;
    if (api != null && api.isNotEmpty) return api.length;
    return HomeHeroCarousel._fallbackSlideKeys.length;
  }

  String _lineAt(BuildContext context, int i) {
    final api = widget.slidesFromApi;
    if (api != null && api.isNotEmpty && i < api.length) {
      final ar = Localizations.localeOf(context).languageCode == 'ar';
      final s = api[i];
      if (ar && (s.textAr?.isNotEmpty ?? false)) return s.textAr!;
      return s.text;
    }
    return AppStrings.tr(context, HomeHeroCarousel._fallbackSlideKeys[i]);
  }

  String _ctaLabel(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (widget.reportCtaAr?.isNotEmpty ?? false)) return widget.reportCtaAr!;
    if (!ar && (widget.reportCtaEn?.isNotEmpty ?? false)) return widget.reportCtaEn!;
    if (widget.reportCtaEn?.isNotEmpty ?? false) return widget.reportCtaEn!;
    if (widget.reportCtaAr?.isNotEmpty ?? false) return widget.reportCtaAr!;
    return AppStrings.tr(context, 'reportAnIssue');
  }

  @override
  Widget build(BuildContext context) {
    final count = _slideCount(context);
    final url = widget.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: AppStrings.tr(context, 'homeReportHeroCarousel'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroImage(url: url),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  PageView.builder(
                    controller: _controller,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          child: Text(
                            _lineAt(context, i),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 22 / 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(count, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.onReport,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _ctaLabel(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 22 / 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u != null && u.isNotEmpty && (u.startsWith('http://') || u.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: u,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppTheme.maroon.withValues(alpha: 0.15),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
        ),
        errorWidget: (_, __, ___) => _AssetFallback(),
      );
    }
    return _AssetFallback();
  }
}

class _AssetFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      HomeHeroCarousel._fallbackAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.maroon.withValues(alpha: 0.25),
              AppTheme.maroon.withValues(alpha: 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
