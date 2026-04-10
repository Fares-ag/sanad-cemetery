/// Optional overrides via `--dart-define=AWQAF_DASHBOARD_URL=https://...`
class AppExternalUrls {
  AppExternalUrls._();

  static const String awqafDashboard = String.fromEnvironment(
    'AWQAF_DASHBOARD_URL',
    defaultValue: 'http://localhost:5174',
  );
}
