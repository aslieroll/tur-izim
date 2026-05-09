/// Başvuru ve depozito son onayındaki üçlü taahhüt (kapı şartı).
class ApplicationCommitment {
  const ApplicationCommitment({
    required this.acceptedPublicationCommitment,
    required this.acceptedContentUsagePermission,
    required this.acceptedTourPriceClaimCondition,
  });

  final bool acceptedPublicationCommitment;
  final bool acceptedContentUsagePermission;
  final bool acceptedTourPriceClaimCondition;

  bool get isComplete =>
      acceptedPublicationCommitment &&
      acceptedContentUsagePermission &&
      acceptedTourPriceClaimCondition;
}
