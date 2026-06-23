import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <-- Import package provider
import 'core/theme/app_colors.dart';
import 'screens/main_wrapper.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart'; // <-- Import file provider yang baru kita bikin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi Firebase Web lu
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBs2AWFfgS_d8dqO6-Q2wjptKjbpHzR_kc",
      authDomain: "sawitproject-a1458.firebaseapp.com",
      projectId: "sawitproject-a1458",
      storageBucket: "sawitproject-a1458.firebasestorage.app",
      messagingSenderId: "988651721012",
      appId: "1:988651721012:web:d29afd62c9d2d94ae21561",
    ),
  );

  // Bungkus aplikasi pake MultiProvider biar "otak tengahnya" aktif
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const SawOfItApp(),
    ),
  );
}

class SawOfItApp extends StatelessWidget {
  const SawOfItApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SawOfIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGold,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGold),
        fontFamily: 'Roboto', 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainWrapper(),
    );
  }
}