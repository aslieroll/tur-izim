/// Backend `SubscriptionPlanCode` enum ile birebir eşleşir.
enum AgencySubscriptionPlanCode { free, agencyPro, agencyGrowth }

/// Backend `SubscriptionStatus` enum ile birebir eşleşir.
enum AgencySubscriptionStatus { none, pending, active, pastDue, canceled }

/// Acente abonelik durumu; `GET /api/billing/agency/subscription` yanıtından doldurulur.
class AgencySubscription {
  const AgencySubscription({
    required this.planCode,
    required this.status,
    required this.activeTourLimit,
    required this.canUseAiMatch,
    required this.canManageApplicants,
    required this.canSelectCreator,
    this.currentPeriodEnd,
  });

  final AgencySubscriptionPlanCode planCode;
  final AgencySubscriptionStatus status;
  final int activeTourLimit;
  final bool canUseAiMatch;
  final bool canManageApplicants;
  final bool canSelectCreator;
  final DateTime? currentPeriodEnd;

  bool get isActive => status == AgencySubscriptionStatus.active;
  bool get isPaid => isActive && planCode != AgencySubscriptionPlanCode.free;

  factory AgencySubscription.fromJson(Map<String, dynamic> json) {
    return AgencySubscription(
      planCode: _planCodeFrom(json['planCode']?.toString()),
      status: _statusFrom(json['status']?.toString()),
      activeTourLimit: (json['activeTourLimit'] as num?)?.toInt() ?? 1,
      canUseAiMatch: json['canUseAiMatch'] == true,
      canManageApplicants: json['canManageApplicants'] == true,
      canSelectCreator: json['canSelectCreator'] == true,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.tryParse(json['currentPeriodEnd'].toString())
          : null,
    );
  }

  static AgencySubscriptionPlanCode _planCodeFrom(String? raw) {
    return switch (raw?.toUpperCase()) {
      'AGENCY_PRO' => AgencySubscriptionPlanCode.agencyPro,
      'AGENCY_GROWTH' => AgencySubscriptionPlanCode.agencyGrowth,
      _ => AgencySubscriptionPlanCode.free,
    };
  }

  static AgencySubscriptionStatus _statusFrom(String? raw) {
    return switch (raw?.toUpperCase()) {
      'ACTIVE' => AgencySubscriptionStatus.active,
      'PENDING' => AgencySubscriptionStatus.pending,
      'PAST_DUE' => AgencySubscriptionStatus.pastDue,
      'CANCELED' => AgencySubscriptionStatus.canceled,
      _ => AgencySubscriptionStatus.none,
    };
  }

  /// Demo / mock modda kullanılan varsayılan (Pro ACTIVE).
  static const AgencySubscription mockActive = AgencySubscription(
    planCode: AgencySubscriptionPlanCode.agencyPro,
    status: AgencySubscriptionStatus.active,
    activeTourLimit: 5,
    canUseAiMatch: true,
    canManageApplicants: true,
    canSelectCreator: true,
  );

  /// Abonelik yok / FREE varsayılan.
  static const AgencySubscription free = AgencySubscription(
    planCode: AgencySubscriptionPlanCode.free,
    status: AgencySubscriptionStatus.none,
    activeTourLimit: 1,
    canUseAiMatch: false,
    canManageApplicants: false,
    canSelectCreator: false,
  );
}
