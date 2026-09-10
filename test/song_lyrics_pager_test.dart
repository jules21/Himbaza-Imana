import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirimbo/widgets/song_lyrics_pager.dart';

void main() {
  testWidgets('keeps the title fixed while lyrics move between inset pages',
      (tester) async {
    final controller = PageController(viewportFraction: 0.92);
    addTearDown(controller.dispose);
    var currentPage = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongLyricsPager(
            title: '1. Fixed song title',
            controller: controller,
            itemCount: 2,
            onPageChanged: (index) => currentPage = index,
            itemBuilder: (context, index) => Text(
              index == 0 ? 'First lyrics' : 'Second lyrics',
            ),
          ),
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('1. Fixed song title'),
        matching: find.byType(PageView),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.text('First lyrics'),
        matching: find.byType(PageView),
      ),
      findsOneWidget,
    );
    final pagerBounds = tester.getRect(find.byType(PageView));
    final cardBounds = tester.getRect(find.byType(Card).first);
    expect(cardBounds.width, lessThan(800));
    expect(cardBounds.top, pagerBounds.top);
    expect(cardBounds.bottom, pagerBounds.bottom);

    unawaited(
      controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      ),
    );
    await tester.pumpAndSettle();

    expect(currentPage, 1);
    expect(find.text('1. Fixed song title'), findsOneWidget);
    expect(find.text('Second lyrics'), findsOneWidget);
  });
}
