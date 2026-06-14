import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/features/billing/domain/agency_plan.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/features/billing/domain/billing_repository.dart';

class ApiBillingRepository implements BillingRepository {
  const ApiBillingRepository(this._client);

  final TurIzimApiClient _client;

  @override
  Future<AgencySubscription> getSubscription(String agencyId) async {
    final json = await _client.getJson('/api/billing/agency/subscription');
    return AgencySubscription.fromJson(json);
  }

  @override
  Future<List<AgencyPlan>> getPlans() async {
    final list = await _client.getJsonList('/api/billing/agency/plans');
    return list
        .whereType<Map<String, dynamic>>()
        .map(AgencyPlan.fromJson)
        .toList();
  }

  @override
  Future<String?> getCheckoutUrl(String agencyId, String planCode) async {
    final json = await _client.postJson(
      '/api/billing/agency/checkout',
      {'planCode': planCode},
    );
    final url = json['checkoutUrl']?.toString();
    return url?.isNotEmpty == true ? url : null;
  }
}
