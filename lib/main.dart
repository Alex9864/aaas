import 'package:aaas/pages/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ProviderModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderModel(),
      child: MaterialApp(
          title: 'aaas',
          theme: ThemeData(
            primaryColor: Colors.orange,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          home: const WelcomePage(),
          debugShowCheckedModeBanner: false
      ),
    );
  }
}