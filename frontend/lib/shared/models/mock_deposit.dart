import 'mock_deposit_status.dart';

/// Mock ödeme/blokaj kaydı (gerçek kart veya ödeme yok).
class MockDeposit {
  const MockDeposit({
    required this.id,
    required this.assignmentId,
    required this.tourId,
    required this.creatorId,
    required this.agencyId,
    required this.status,
    required this.amountSnapshot,
  });

  final String id;
  final String assignmentId;
  final String tourId;
  final String creatorId;
  final String agencyId;
  final MockDepositStatus status;
  final double amountSnapshot;
}
