class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  bool _isScannerActive = false;

  factory ScannerService() {
    return _instance;
  }

  ScannerService._internal();

  bool get isScannerActive => _isScannerActive;

  void setScannerActive(bool isActive) {
    _isScannerActive = isActive;
  }
}
