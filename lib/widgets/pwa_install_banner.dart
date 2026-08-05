import 'package:flutter/material.dart';
import '../services/pwa_install_service.dart';

class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({required this.child, super.key});
  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  late final PwaInstallService _installer = PwaInstallService()
    ..addListener(_refresh);

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _installer.removeListener(_refresh);
    _installer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_installer.canInstall)
          MaterialBanner(
            content: const Text('Shyira Indirimbo kuri iki gikoresho kugira ngo uyikoreshe offline.'),
            leading: const Icon(Icons.install_mobile_rounded),
            actions: [
              TextButton(onPressed: _installer.dismiss, child: const Text('OYA')),
              FilledButton(
                onPressed: _installer.promptInstall,
                child: const Text('SHYIRAHO'),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
