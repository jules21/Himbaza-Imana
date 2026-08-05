import 'package:flutter/material.dart';
import 'package:indirimbo/page/home.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:indirimbo/widgets/pwa_install_banner.dart';
import 'package:indirimbo/widgets/responsive_app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WakelockPlus.enable();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SongCollectionProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      )
    ],
    child: const IndirimboApp(),
  ));
}

class IndirimboApp extends StatelessWidget {
  const IndirimboApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      builder: (context, child) => PwaInstallBanner(
        child: ResponsiveAppShell(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
