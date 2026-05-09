/// İleride HTTP istemcisi burada soyutlanacak (MVP: gerçek çağrı yok).
abstract class ApiClient {
  Future<void> dispose();
}
