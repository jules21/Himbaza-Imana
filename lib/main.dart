import 'package:flutter/material.dart';
import 'package:indirimbo/page/home.dart';
import 'package:indirimbo/providers/songs_provider.dart';
import 'package:indirimbo/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) =>  SongCollectionProvider(),),
       ChangeNotifierProvider(create: (context) =>  ThemeProvider(),
       )
    ],
    child: IndirimboApp(),
    )
  );
}

class IndirimboApp extends StatelessWidget{
  const IndirimboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: Provider.of<ThemeProvider>(context).themeData
    );
  }

}