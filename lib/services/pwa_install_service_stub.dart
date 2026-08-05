import 'package:flutter/foundation.dart';

class PwaInstallService extends ChangeNotifier {
  bool get canInstall => false;
  Future<bool> promptInstall() async => false;
  void dismiss() {}
}
