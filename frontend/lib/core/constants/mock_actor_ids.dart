/// Deterministic actor identifiers shared by mock repositories + UX seeds.
abstract final class MockActorIds {
  MockActorIds._();

  static const String approvedAgency = 'agency-approved-1';
  static const String pendingAgency = 'agency-pending-approval';
  static const String creatorAlice = 'creator-alice';
  static const String creatorBob = 'creator-bob';
  static const String tourKapadokya = 'tour-kapadokya-1';

  /// İkinci yayımlanmış ilan (üretici listesi çeşitliliği).
  static const String tourAntalyaCoast = 'tour-antalya-coast-1';

  /// Yurt dışı pasaport/vize şartlı yayımlanmış ilan (MVP filtre senaryosu).
  static const String tourInternationalIslands = 'tour-international-islands-1';

  /// Aynı onaylı acenteye ait taslak ilan (acenteye özel senaryo).
  static const String tourAdanaDraft = 'tour-adana-draft-1';
}
