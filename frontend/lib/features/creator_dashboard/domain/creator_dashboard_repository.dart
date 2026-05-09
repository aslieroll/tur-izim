import 'package:tur_izim/shared/models/creator_home_peek.dart';

abstract class CreatorDashboardRepository {
  Future<CreatorHomePeek> loadHomePeek(String creatorId);
}
