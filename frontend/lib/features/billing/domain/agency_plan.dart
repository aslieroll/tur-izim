/// Backend `GET /api/billing/agency/plans` yanıtındaki plan kartı.
class AgencyPlan {
  const AgencyPlan({
    required this.planCode,
    required this.displayName,
    required this.priceMonthlyTl,
    required this.activeTourLimit,
    required this.canUseAiMatch,
    required this.canManageApplicants,
    required this.canSelectCreator,
    required this.prioritySupport,
    required this.checkoutAvailable,
  });

  final String planCode;
  final String displayName;
  final int priceMonthlyTl;
  final int activeTourLimit;
  final bool canUseAiMatch;
  final bool canManageApplicants;
  final bool canSelectCreator;
  final bool prioritySupport;
  final bool checkoutAvailable;

  bool get isFree => planCode == 'FREE';

  factory AgencyPlan.fromJson(Map<String, dynamic> json) {
    return AgencyPlan(
      planCode: json['planCode']?.toString() ?? 'FREE',
      displayName: json['displayName']?.toString() ?? 'Plan',
      priceMonthlyTl: (json['priceMonthlyTl'] as num?)?.toInt() ?? 0,
      activeTourLimit: (json['activeTourLimit'] as num?)?.toInt() ?? 1,
      canUseAiMatch: json['canUseAiMatch'] == true,
      canManageApplicants: json['canManageApplicants'] == true,
      canSelectCreator: json['canSelectCreator'] == true,
      prioritySupport: json['prioritySupport'] == true,
      checkoutAvailable: json['checkoutAvailable'] == true,
    );
  }

  static final List<AgencyPlan> staticPlans = [
    const AgencyPlan(
      planCode: 'FREE',
      displayName: 'Ücretsiz',
      priceMonthlyTl: 0,
      activeTourLimit: 1,
      canUseAiMatch: false,
      canManageApplicants: false,
      canSelectCreator: false,
      prioritySupport: false,
      checkoutAvailable: false,
    ),
    const AgencyPlan(
      planCode: 'AGENCY_PRO',
      displayName: 'Agency Pro',
      priceMonthlyTl: 499,
      activeTourLimit: 5,
      canUseAiMatch: true,
      canManageApplicants: true,
      canSelectCreator: true,
      prioritySupport: false,
      checkoutAvailable: false,
    ),
    const AgencyPlan(
      planCode: 'AGENCY_GROWTH',
      displayName: 'Agency Growth',
      priceMonthlyTl: 999,
      activeTourLimit: 20,
      canUseAiMatch: true,
      canManageApplicants: true,
      canSelectCreator: true,
      prioritySupport: true,
      checkoutAvailable: false,
    ),
  ];
}
