import 'package:aaas/pages/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ProviderModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:json_theme/json_theme.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:convert'; // For jsonDecode

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;

  const MyApp({Key? key, required this.theme}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderModel(),
      child: MaterialApp(
          theme: theme,
          title: 'Spérienzha',
          home: const WelcomePage(),
          debugShowCheckedModeBanner: false
      ),
    );
  }
}