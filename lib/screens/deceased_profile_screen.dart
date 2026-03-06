import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:uuid/uuid.dart';
import '../models/deceased.dart';
import '../services/search_service.dart';
import '../theme/app_theme.dart';

String _monthName(int month) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return m[month - 1];
}

/// Deceased profile — aligned to home page: white background, maroon accent, same typography & cards.
class DeceasedProfileScreen extends StatelessWidget {
  static const _maroon = Color(0xFF8E1737);

  final String graveId;

  const DeceasedProfileScreen({super.key, required this.graveId});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SearchService>();
    final d = service.getById(graveId);
    if (d == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.personOff, size: 64, color: Colors.black.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                AppStrings.tr(context, 'profileNotFound'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
      );
    }
    final dateStr = d.deathDate != null
        ? '${d.deathDate!.day.toString().padLeft(2, '0')}-${_monthName(d.deathDate!.month)}-${d.deathDate!.year}'
        : '${d.deathYear ?? '?'}';
    final yearsInterred = d.deathYear != null && d.deathYear! > 0
        ? DateTime.now().year - d.deathYear!
        : null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.tr(context, 'searchForDeceased'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    child: Text(
                      (d.fullName.isNotEmpty ? d.fullName[0] : '?').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                      ),
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
                            height: 24 / 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${AppStrings.tr(context, 'age')}: ${d.birthDate != null ? (d.deathYear ?? DateTime.now().year) - d.birthDate!.year : '?'}',
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (d.imageUrls.length > 1) _Gallery(images: d.imageUrls),
            if (d.legacyVideoUrl != null && d.legacyVideoUrl!.isNotEmpty)
              _LegacyVideo(url: d.legacyVideoUrl!, maxDurationSeconds: d.legacyVideoDurationSeconds),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (d.sectionId != null || d.plotNumber != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${AppStrings.tr(context, 'graveNumber')}: ${d.plotNumber ?? d.sectionId ?? '?'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    if (d.imageUrls.isNotEmpty)
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: d.imageUrls.first.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: d.imageUrls.first,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(d.imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(AppIcons.image, size: 48)),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Image.asset(
                            'images/grave-img.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: Colors.black.withOpacity(0.05),
                              alignment: Alignment.center,
                              child: Text(
                                d.fullName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.fullName,
                            style: TextStyle(fontSize: 14, height: 20 / 14, color: Colors.black.withOpacity(0.5)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.tr(context, 'passedAway')}: $dateStr',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 20 / 14,
                              color: Colors.black,
                            ),
                          ),
                          if (yearsInterred != null)
                            Text(
                              '${AppStrings.tr(context, 'yearsInterred')}: $yearsInterred',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: Colors.black.withOpacity(0.2)),
                        foregroundColor: _maroon,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(AppStrings.tr(context, 'share')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.push('/navigate/${d.id}'),
                      style: TextButton.styleFrom(
                        backgroundColor: _maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        AppStrings.tr(context, 'viewGraveLocation'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 22 / 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.location, color: _maroon, size: AppIcons.sizeLg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${d.birthYear ?? '?'} – ${d.deathYear ?? '?'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 24 / 16,
                      color: Colors.black,
                    ),
                  ),
                  if (d.isVeteran)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _maroon,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${AppStrings.tr(context, 'veteran')}${d.branchOfService != null ? ' · ${d.branchOfService}' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (d.sectionId != null || d.plotNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${AppStrings.tr(context, 'section')} ${d.sectionId ?? '?'}, ${AppStrings.tr(context, 'plot')} ${d.plotNumber ?? '?'}',
                        style: TextStyle(fontSize: 12, height: 16 / 12, color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  if (d.bioHtml != null && d.bioHtml!.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.tr(context, 'lifeStory'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 24 / 18, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Html(data: d.bioHtml!, style: {'body': Style(margin: Margins.zero)}),
                  ],
                  if (d.familyLinks.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.tr(context, 'family'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 24 / 18, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: d.familyLinks.map((f) => ActionChip(
                        label: Text('${f.label}: ${f.name}'),
                        onPressed: () => context.push('/grave/${f.deceasedId}'),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _LeaveFlowerButton(deceased: d, searchService: service),
                  const SizedBox(height: 12),
                  _TributesList(tributes: d.tributes.where((t) => !t.isExpired).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;

  const _Gallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (_, i) {
          final url = images[i];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url.startsWith('http')
                  ? CachedNetworkImage(imageUrl: url, width: 280, height: 220, fit: BoxFit.cover)
                  : Image.asset(url, width: 280, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(AppIcons.image, size: 80)),
            ),
          );
        },
      ),
    );
  }
}

class _LegacyVideo extends StatefulWidget {
  final String url;
  final int maxDurationSeconds;

  const _LegacyVideo({required this.url, required this.maxDurationSeconds});

  @override
  State<_LegacyVideo> createState() => _LegacyVideoState();
}

class _LegacyVideoState extends State<_LegacyVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppStrings.tr(context, 'legacyVideo'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 24 / 18, color: Colors.black),
          ),
        ),
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        Center(
          child: IconButton(
            icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () => setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play()),
          ),
        ),
      ],
    );
  }
}

class _LeaveFlowerButton extends StatelessWidget {
  final Deceased deceased;
  final SearchService searchService;

  const _LeaveFlowerButton({required this.deceased, required this.searchService});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: DeceasedProfileScreen._maroon,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        final tribute = Tribute(id: const Uuid().v4(), placedAt: DateTime.now(), iconType: 'flower');
        final updated = Deceased(
          id: deceased.id,
          firstName: deceased.firstName,
          middleName: deceased.middleName,
          lastName: deceased.lastName,
          maidenName: deceased.maidenName,
          birthDate: deceased.birthDate,
          deathDate: deceased.deathDate,
          isVeteran: deceased.isVeteran,
          branchOfService: deceased.branchOfService,
          lat: deceased.lat,
          lon: deceased.lon,
          sectionId: deceased.sectionId,
          plotNumber: deceased.plotNumber,
          bioHtml: deceased.bioHtml,
          imageUrls: deceased.imageUrls,
          legacyVideoUrl: deceased.legacyVideoUrl,
          legacyVideoDurationSeconds: deceased.legacyVideoDurationSeconds,
          familyLinks: deceased.familyLinks,
          tributes: [...deceased.tributes, tribute],
          qrCodeData: deceased.qrCodeData,
        );
        searchService.addOrUpdateRecord(updated);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.tr(context, 'flowerPlaced'))));
      },
      icon: const Icon(AppIcons.flower),
      label: Text(AppStrings.tr(context, 'leaveFlower')),
    );
  }
}

class _TributesList extends StatelessWidget {
  final List<Tribute> tributes;

  const _TributesList({required this.tributes});

  @override
  Widget build(BuildContext context) {
    if (tributes.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tributes.map((t) => Chip(
        avatar: const Icon(AppIcons.flower, color: Colors.pink, size: AppIcons.sizeMd),
        label: Text(t.senderName ?? AppStrings.tr(context, 'someone')),
      )).toList(),
    );
  }
}
