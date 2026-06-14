import 'package:tur_izim/features/billing/domain/agency_plan.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/features/billing/domain/billing_repository.dart';

/// Mock implementasyon: backend kapalıyken veya test ortamında kullanılır.
///
/// Demo akışının bozulmaması için Pro ACTIVE döner.
/// [getCheckoutUrl] demo modda null döner (backend yok).
class MockBillingRepository implements BillingRepository {
  const MockBillingRepository();

  @override
  Future<AgencySubscription> getSubscription(String agencyId) async {
    return AgencySubscription.mockActive;
  }

  @override
  Future<List<AgencyPlan>> getPlans() async {
    return AgencyPlan.staticPlans;
  }

  @override
  Future<String?> getCheckoutUrl(String agencyId, String planCode) async {
    return null;
  }
}
