enum AssignmentStatus {
  /// Seçim yapıldı; kesin üretici onayı ve depozito sonraki aşamada.
  awaitingCreatorConfirmation,
  pendingDeposit,
  active,
  waitingContentDraft,
  waitingAgencyApproval,
  revisionRequested,
  waitingPublication,
  publicationSubmitted,
  depositReleased,
  under30DayMonitoring,
  completed,
  violationReported,
  cancelled,
}
