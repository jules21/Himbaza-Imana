import 'package:flutter/material.dart';

class SongNavigationBar extends StatelessWidget {
  const SongNavigationBar({
    super.key,
    required this.currentIndex,
    required this.songCount,
    required this.onNavigate,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final int currentIndex;
  final int songCount;
  final ValueChanged<int> onNavigate;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < songCount - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _button(Icons.first_page, 'First song',
              hasPrevious ? () => onNavigate(0) : null),
          _button(Icons.chevron_left, 'Previous song',
              hasPrevious ? () => onNavigate(currentIndex - 1) : null),
          Text('${currentIndex + 1} / $songCount',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600)),
          _button(Icons.chevron_right, 'Next song',
              hasNext ? () => onNavigate(currentIndex + 1) : null),
          _button(Icons.last_page, 'Last song',
              hasNext ? () => onNavigate(songCount - 1) : null),
          IconButton(
            onPressed: onToggleFavorite,
            tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback? onPressed) =>
      IconButton.filledTonal(
          icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
}
