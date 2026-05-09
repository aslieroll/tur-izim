import '../models/tour_requirement_type.dart';

/// Short labels for requirement chips on tour detail (schema enum → TR copy).
String tourRequirementShortLabelTurkish(TourRequirementType t) => switch (t) {
  TourRequirementType.min1080pVideo => '1080p video',
  TourRequirementType.verticalReelsFormat => 'Dikey format',
  TourRequirementType.min5Photos => 'Min. 5 foto (teslim checklist)',
  TourRequirementType.min3Locations => 'Min. 3 lokasyon',
  TourRequirementType.daylightShooting => 'Gün ışığı çekimi',
  TourRequirementType.rawFilesIncluded => 'Ham dosya dahil teslim',
  TourRequirementType.agencyBrandVisible => 'Marka görünür (teslim)',
  TourRequirementType.basicEditing => 'Temel düzenleme yeteneği',
  TourRequirementType.travelVlogExperience => 'Seyahat vlog deneyimi',
  TourRequirementType.instagramPublication => 'Instagram yayını',
  TourRequirementType.tiktokPublication => 'TikTok yayını',
  TourRequirementType.agencyTagRequired => 'Etiket zorunluluğu',
  TourRequirementType.thirtyDaysPublicationRequired => '30 gün yayın (teslim)',
};
