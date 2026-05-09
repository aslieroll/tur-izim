import 'application_status.dart';

/// Rows shaped like future `applications` list API responses.
class ApplicationSummary {
  const ApplicationSummary({
    required this.id,
    required this.tourId,
    required this.status,
    this.message,
    this.tourTitle,
    this.agencyLegalName,
    this.suitabilityAue,
  });

  final String id;
  final String tourId;
  final ApplicationStatus status;

  /// Optional applicant note (`applications.message`).
  final String? message;

  /// Liste görünümü için mock/API birleşik alanlar.
  final String? tourTitle;
  final String? agencyLegalName;

  /// Önceden hesaplanmış uygunluk özet skoru (AUE).
  final double? suitabilityAue;
}
