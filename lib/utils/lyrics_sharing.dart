import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void showLyricsCopiedSnackBar(
  BuildContext context, {
  required String text,
  required String title,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Lyrics copied'),
      action: SnackBarAction(
        label: 'Share',
        onPressed: () async {
          await _shareLyrics(context, text: text, title: title);
        },
      ),
    ),
  );
}

Future<void> _shareLyrics(
  BuildContext context, {
  required String text,
  required String title,
}) async {
  try {
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: title,
      sharePositionOrigin: overlayBox == null
          ? null
          : overlayBox.localToGlobal(Offset.zero) & overlayBox.size,
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open sharing options. Please restart the app and try again.',
        ),
      ),
    );
  }
}
