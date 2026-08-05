// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

class PwaInstallService extends ChangeNotifier {
  html.Event? _installEvent;
  StreamSubscription<html.Event>? _subscription;

  PwaInstallService() {
    _subscription = html.window.on['beforeinstallprompt']?.listen((event) {
      event.preventDefault();
      _installEvent = event;
      notifyListeners();
    });
  }

  bool get canInstall => _installEvent != null;

  Future<bool> promptInstall() async {
    final event = _installEvent;
    if (event == null) return false;
    await js_util.promiseToFuture<Object?>(js_util.callMethod(event, 'prompt', const []));
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
    _subscription?.cancel();
    super.dispose();
  }
}
