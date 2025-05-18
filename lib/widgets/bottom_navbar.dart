import 'package:flutter/material.dart';
import '../screens/games/game_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/quests/quest_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Index tab yang aktif saat ini

  // List halaman yang akan ditampilkan sesuai index navbar
  final List<Widget> _pages = [
    const HomeScreen(), // Halaman Home
    const QuestScreen(), // Halaman Quest
    const GameScreen(), // Halaman Game
    const LeaderboardScreen(), // Halaman Leaderboard
    const ProfileScreen(), // Halaman Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state halaman ketika berpindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // BottomNavigationBar untuk navigasi antar halaman
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Tab yang aktif
        onTap: (index) => setState(() => _currentIndex = index), // Update tab saat ditekan
        type: BottomNavigationBarType.fixed, // Menampilkan semua icon tanpa scroll
        backgroundColor: Theme.of(context).colorScheme.surface, // Warna background navbar
        selectedItemColor: Theme.of(context).colorScheme.primary, // Warna icon/tab aktif
        unselectedItemColor: Colors.grey, // Warna icon/tab tidak aktif
        elevation: 8, // Shadow di atas navbar
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Style label aktif (meskipun label disembunyikan)
        showSelectedLabels: false, // Sembunyikan label tab aktif
        showUnselectedLabels: false, // Sembunyikan label tab tidak aktif
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Icon saat tidak aktif
            activeIcon: Icon(Icons.home), // Icon saat aktif
            label: '', // Label dikosongkan supaya tidak muncul teks
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
