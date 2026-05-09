import 'package:tur_izim/shared/models/agency_status.dart';

String agencyStatusLabelTurkish(AgencyStatus status) => switch (status) {
      AgencyStatus.pendingApproval => 'Onay bekliyor',
      AgencyStatus.approved => 'Onaylı',
      AgencyStatus.rejected => 'Reddedildi',
      AgencyStatus.suspended => 'Askıda',
    };
