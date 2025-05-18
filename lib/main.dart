import 'package:eco_quest/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'config/app_constants.dart';
import 'config/app_theme.dart';
import 'screens/auth/authentication_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/quests/quest_screen.dart';
import 'screens/games/game_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pastikan binding Flutter sudah siap sebelum inisialisasi Firebase
  await Firebase.initializeApp(); // Inisialisasi Firebase sebelum app berjalan
  runApp(const EcoQuestApp()); // Jalankan aplikasi
}

class EcoQuestApp extends StatelessWidget {
  const EcoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName, // Judul aplikasi
      theme: AppTheme.lightTheme, // Theme yang digunakan di aplikasi
      debugShowCheckedModeBanner: false, // Hilangkan banner debug
      initialRoute: '/', // Rute awal aplikasi
      routes: {
        '/': (context) => const AuthScreen(), // Halaman autentikasi utama (login/register)
        AppConstants.registerRoute: (context) => const RegisterScreen(), // Halaman registrasi
        AppConstants.loginRoute: (context) => const LoginScreen(), // Halaman login
        AppConstants.homeRoute: (context) => const BottomNavBar(), // Halaman utama dengan BottomNavBar
        AppConstants.questsRoute: (context) => const QuestScreen(), // Halaman quest (opsional)
        AppConstants.gamesRoute: (context) => const GameScreen(), // Halaman game (opsional)
      },
    );
  }
}
