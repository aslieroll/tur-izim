enum AssignmentTimelinePhase {
  awaitingCreatorConfirmation,
  awaitingDepositConfirmation,
  waitingDraftSubmission,
  waitingAgencyReview,
  awaitingPublicationSubmission,
  depositReleased,
  monitoring30Days,
}

/// Depo/maket tarafından sıralı verilen küçük görünüm modeli.
class AssignmentTimelineStep {
  const AssignmentTimelineStep({
    required this.phase,
    required this.label,
    required this.isComplete,
    required this.timestamp,
  });

  final AssignmentTimelinePhase phase;
  final String label;
  final bool isComplete;
  final DateTime? timestamp;
}
