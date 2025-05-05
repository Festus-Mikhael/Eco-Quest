import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../models/user_model.dart';
import '../../models/quest_model.dart';
import '../home/components/profile_section.dart';
import '../home/components/active_quest.dart';
import '../home/components/leaderboard.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  UserModel? currentUser;
  QuestModel? activeQuest;
  List<Map<String, dynamic>> leaderboard = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _fetchEssentialData();
    } catch (e) {
      _logger.e('Initial data load failed', error: e);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEssentialData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await _fetchUserProfile(user);
      await _fetchActiveQuest(user);
      await _fetchLeaderboard();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      _logger.e('Fetch data error', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _fetchUserProfile(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      UserModel newUser;

      if (!doc.exists) {
        newUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'New User',
          email: user.email ?? '',
          avatarUrl: user.photoURL ?? 'https://placehold.co/100x100/png?text=User',
          points: 0,
          badges: [],
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      } else {
        newUser = UserModel.fromFirestore(doc);
      }

      if (mounted) {
        setState(() => currentUser = newUser);
      }
    } catch (e) {
      _logger.e('Failed to fetch user profile', error: e);
      if (mounted) {
        setState(() {
          currentUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            avatarUrl: user.photoURL ?? 'https://placehold.co/100x100/png?text=User',
            points: 0,
            badges: [],
          );
        });
      }
    }
  }

  Future<void> _fetchActiveQuest(User user) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('userQuests')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        if (mounted) {
          setState(() {
            activeQuest = QuestModel(
              id: doc.id,
              title: doc['title'] ?? 'Untitled Quest',
              description: doc['description'] ?? '',
              points: doc['points'] ?? 0,
              status: QuestStatus.inProgress,
            );
          });
        }
      }
    } catch (e) {
      _logger.e('Failed to fetch active quest', error: e);
    }
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(10)
          .get();

      if (mounted) {
        setState(() {
          leaderboard = snapshot.docs.map((doc) {
            return {
              'name': doc['name'] ?? 'Anonymous',
              'email': doc['email'] ?? '',
              'avatarUrl': doc['avatarUrl'] ?? 'https://placehold.co/100x100/png?text=User',
              'points': doc['points'] ?? 0,
            };
          }).toList();
        });
      }
    } catch (e) {
      _logger.e('Failed to fetch leaderboard', error: e);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _logger.e('Logout failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  void _onNavTap(int index) {
    if (!mounted) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/quests');
        break;
      case 2:
        Navigator.pushNamed(context, '/games');
        break;
    }
  }

  Future<void> _retryLoading() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError && currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load data'),
              ElevatedButton(
                onPressed: _retryLoading,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            currentUser != null
                ? ProfileSection(user: currentUser!)
                : const Placeholder(),

            activeQuest != null
                ? ActiveQuest(quest: activeQuest!)
                : const Text('No active quests'),

            Leaderboard(
              leaderboardData: leaderboard,
              currentUserEmail: currentUser?.email ?? '',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}