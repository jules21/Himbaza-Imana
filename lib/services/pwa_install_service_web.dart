import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

extension type _BeforeInstallPromptEvent._(JSObject _)
    implements web.Event, JSObject {
  external JSPromise<JSAny?> prompt();
}

class PwaInstallService extends ChangeNotifier {
  _BeforeInstallPromptEvent? _installEvent;
  late final JSFunction _beforeInstallPromptListener;

  PwaInstallService() {
    _beforeInstallPromptListener = ((web.Event event) {
      event.preventDefault();
      _installEvent = _BeforeInstallPromptEvent._(event as JSObject);
      notifyListeners();
    }).toJS;
    web.window.addEventListener(
      'beforeinstallprompt',
      _beforeInstallPromptListener,
    );
  }

  bool get canInstall => _installEvent != null;

  Future<bool> promptInstall() async {
    final event = _installEvent;
    if (event == null) return false;
    await event.prompt().toDart;
    _installEvent = null;
    notifyListeners();
    return true;
  }

  void dismiss() {
    _installEvent = null;
    notifyListeners();
  }

  @override
  void dispose() {
    web.window.removeEventListener(
      'beforeinstallprompt',
      _beforeInstallPromptListener,
    );
    super.dispose();
  }
}
