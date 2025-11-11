import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_app/providers/apiList_provider.dart';
import 'package:twitter_app/providers/banner_provider.dart';
import 'package:twitter_app/providers/details_Providers.dart';
import 'package:twitter_app/providers/recommended_provider.dart';
import 'package:twitter_app/screen/home.dart';

import 'screen/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementsProvider()),
        ChangeNotifierProvider(create: (_) => RecommendedProvider()),
        ChangeNotifierProvider(create: (_) => OtherProvider()),
        ChangeNotifierProvider(create: (_) => DatingZoneProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5BAE)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),   // Splash -> Nav/Home
      debugShowCheckedModeBanner: false,
    );
  }
}
