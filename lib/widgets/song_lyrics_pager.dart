import 'package:flutter/material.dart';

class SongLyricsPager extends StatelessWidget {
  const SongLyricsPager({
    super.key,
    required this.title,
    required this.controller,
    required this.itemCount,
    required this.onPageChanged,
    required this.itemBuilder,
  });

  final String title;
  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageChanged;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SongTitleHeader(title: title),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: itemCount,
            onPageChanged: onPageChanged,
            allowImplicitScrolling: true,
            physics: const PageScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(3, 12, 3, 4),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom:Radius.circular(4), top: Radius.circular(8) ),
                ),
                child: SelectionArea(
                  child: SingleChildScrollView(
                    key: PageStorageKey<int>(index),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    child: itemBuilder(context, index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SongTitleHeader extends StatelessWidget {
  const _SongTitleHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blueGrey[800],
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.35,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 50,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
