/// MVP / demo kimlik — **gerçek auth yok**.
///
/// Varsayılan: [SessionAuthRepository.primeDemoIdentityFromApi] ile
/// `/api/tours` ve `/api/creators` yanıtlarından gelen UUID’ler (hardcode yok).
///
/// İsteğe bağlı yerel override (CI / özel seed):
/// `--dart-define=DEMO_AGENCY_ID=...` veya `DEMO_CREATOR_ID=...`
abstract final class MvpDemoIdentity {
  MvpDemoIdentity._();

  static const String agencyIdOverride = String.fromEnvironment(
    'DEMO_AGENCY_ID',
    defaultValue: '',
  );

  static const String creatorIdOverride = String.fromEnvironment(
    'DEMO_CREATOR_ID',
    defaultValue: '',
  );
}
