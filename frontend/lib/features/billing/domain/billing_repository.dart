import 'agency_plan.dart';
import 'agency_subscription.dart';

/// Acente abonelik ve checkout API arayüzü.
///
/// Ödeme uygulama içinde işlenmez; [getCheckoutUrl] harici
/// provider URL'sini döner.
abstract interface class BillingRepository {
  /// Acentenin güncel abonelik durumunu ve plan özelliklerini döner.
  Future<AgencySubscription> getSubscription(String agencyId);

  /// Mevcut plan tanımlarını (Free / Pro / Growth) döner.
  Future<List<AgencyPlan>> getPlans();

  /// Verilen plan için backend'den harici checkout URL'sini alır.
  /// Plan yoksa veya hata oluşursa `null` döner.
  Future<String?> getCheckoutUrl(String agencyId, String planCode);
}
