import '../models/destination_cluster.dart';
import '../models/application_status.dart';
import '../models/assignment_status.dart';
import '../models/mock_deposit_status.dart';
import '../models/publication_status.dart';
import '../models/tour_status.dart';
import '../models/violation_report_status.dart';

String violationReportStatusLabelTurkish(ViolationReportStatus status) =>
    switch (status) {
      ViolationReportStatus.open => 'Yeni bildirim',
      ViolationReportStatus.underReview => 'İncelemede',
      ViolationReportStatus.confirmed => 'Doğrulandı',
      ViolationReportStatus.rejected => 'Reddedildi',
      ViolationReportStatus.resolved => 'Çözüldü',
    };

String destinationClusterLabelTurkish(DestinationCluster cluster) =>
    switch (cluster) {
      DestinationCluster.kapadokya => 'Kapadokya',
      DestinationCluster.guney => 'Akdeniz / Antalya çevresi',
    };

String tourStatusLabelTurkish(TourStatus status) => switch (status) {
  TourStatus.draft => 'Taslak',
  TourStatus.published => 'Yayında',
  TourStatus.applicationClosed => 'Başvuru kapalı',
  TourStatus.assigned => 'Atandı',
  TourStatus.completed => 'Tamamlandı',
  TourStatus.cancelled => 'İptal',
};

String applicationStatusLabelTurkish(ApplicationStatus status) =>
    switch (status) {
      ApplicationStatus.pendingReview => 'İncelemede (acente)',
      ApplicationStatus.agencySelected => 'Seçildi (atama)',
      ApplicationStatus.accepted => 'Kabul edildi',
      ApplicationStatus.rejected => 'Reddedildi',
      ApplicationStatus.withdrawn => 'Geri çekildi',
    };

String assignmentStatusLabelTurkish(AssignmentStatus status) =>
    switch (status) {
      AssignmentStatus.awaitingCreatorConfirmation =>
        'Üretici kesin onayı bekleniyor',
      AssignmentStatus.pendingDeposit => 'Depozito bekliyor',
      AssignmentStatus.active => 'Aktif',
      AssignmentStatus.waitingContentDraft => 'Taslak bekliyor',
      AssignmentStatus.waitingAgencyApproval => 'Acente onayı bekleniyor',
      AssignmentStatus.revisionRequested => 'Revizyon istendi',
      AssignmentStatus.waitingPublication => 'Yayın bekleniyor',
      AssignmentStatus.publicationSubmitted => 'Yayın bildirildi',
      AssignmentStatus.depositReleased => 'Depozito serbest',
      AssignmentStatus.under30DayMonitoring => '30 gün izlemede',
      AssignmentStatus.completed => 'Tamamlandı',
      AssignmentStatus.violationReported => 'İhlal bildirimi',
      AssignmentStatus.cancelled => 'İptal',
    };

String mockDepositStatusLabelTurkish(MockDepositStatus status) =>
    switch (status) {
      MockDepositStatus.pending => 'Beklemede (blokaj yok)',
      MockDepositStatus.held => 'Bloke (mock)',
      MockDepositStatus.releasedAfterPublication =>
        'Yayından sonra serbest (mock)',
      MockDepositStatus.forfeited => 'Zayi (mock)',
    };

String publicationStatusLabelTurkish(PublicationStatus status) =>
    switch (status) {
      PublicationStatus.waitingPublication => 'Yayın bekleniyor',
      PublicationStatus.linkSubmitted => 'Bağlantı iletildi',
      PublicationStatus.verified => 'Doğrulandı',
      PublicationStatus.monitoring30Days => '30 gün izleme',
      PublicationStatus.completed30Days => '30 gün tamamlandı',
      PublicationStatus.removalReported => 'Kaldırma bildirildi',
      PublicationStatus.violationConfirmed => 'İhlal doğrulandı',
    };
