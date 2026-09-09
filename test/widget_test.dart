import 'package:flutter_test/flutter_test.dart';
import 'package:indirimbo/main.dart';
import 'package:indirimbo/providers/layout_provider.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts and displays its home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SongCollectionProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ],
        child: const IndirimboApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Himbaza Imana'), findsOneWidget);
  });
}
