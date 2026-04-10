import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Complaints form (placeholder → success).
class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'complaintsTitle'), style: AppTheme.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.tr(context, 'complaintsHint'), style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 5,
              decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'describeIssue')),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.push('/success?msg=thankYouSubmission');
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.maroon),
              child: Text(AppStrings.tr(context, 'submitComplaintToMunicipality')),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestInformationScreen extends StatefulWidget {
  const RequestInformationScreen({super.key});

  @override
  State<RequestInformationScreen> createState() => _RequestInformationScreenState();
}

class _RequestInformationScreenState extends State<RequestInformationScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'requestInfoTitle'), style: AppTheme.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.tr(context, 'requestInfoHint'), style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 5,
              decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'describeIssue')),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.push('/success?msg=thankYouSubmission');
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.maroon),
              child: Text(AppStrings.tr(context, 'submitInfoRequestToMunicipality')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Religious fines / cemetery rule violations — municipality follow-up (Awqaf-only workflows use the Awqaf dashboard).
class ReligiousFinesScreen extends StatefulWidget {
  const ReligiousFinesScreen({super.key});

  @override
  State<ReligiousFinesScreen> createState() => _ReligiousFinesScreenState();
}

class _ReligiousFinesScreenState extends State<ReligiousFinesScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'religiousFinesTitle'), style: AppTheme.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.tr(context, 'religiousFinesHint'), style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 6,
              decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'describeIssue')),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.push('/success?msg=thankYouSubmission');
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.maroon),
              child: Text(AppStrings.tr(context, 'submitReligiousFineReport')),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestGraveLocationScreen extends StatefulWidget {
  const RequestGraveLocationScreen({super.key});

  @override
  State<RequestGraveLocationScreen> createState() => _RequestGraveLocationScreenState();
}

class _RequestGraveLocationScreenState extends State<RequestGraveLocationScreen> {
  final _name = TextEditingController();
  final _details = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'graveRequestTitle'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(AppStrings.tr(context, 'graveRequestHint'), style: AppTheme.bodyMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'enterFullName')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            maxLines: 4,
            decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'describeIssue')),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.push('/success?msg=thankYouSubmission');
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.maroon),
            child: Text(AppStrings.tr(context, 'submitGraveLocationRequest')),
          ),
        ],
      ),
    );
  }
}
