mixin IBLEService {
  Future<void> stopScan();
  Future<void> startScan({Duration? timeout});
}
