import 'package:flutter/material.dart';

import 'package:foodiy/features/playlist/presentation/screens/my_playlists_screen.dart';
import 'package:foodiy/features/discover/presentation/screens/discover_screen.dart';
import 'package:foodiy/features/home/presentation/screens/home_screen.dart';
import 'package:foodiy/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/models/user_type.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => const [
        HomeScreen(),
        DiscoverScreen(),
        MyPlaylistsScreen(),
        UserProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: CurrentUserService.instance.profileNotifier,
      builder: (context, profile, _) {
        // Trigger rebuilds on role/tier changes.
        final userType = profile?.userType ?? UserType.freeUser;
        debugPrint('[USER_ROLE_STREAM] shell rebuild userType=$userType');
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.7),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Cookbooks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
