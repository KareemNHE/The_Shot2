
//views/bnb.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_shot2/services/api_service.dart';
import 'package:the_shot2/views/home_screen.dart';
import 'package:the_shot2/viewmodels/home_viewmodel.dart';
import 'package:the_shot2/views/profile_screen.dart';
import 'package:the_shot2/viewmodels/profile_viewmodel.dart';
import 'package:the_shot2/views/search_screen.dart';
import 'package:the_shot2/viewmodels/search_viewmodel.dart';
import 'package:the_shot2/views/post_screen.dart';
import 'package:the_shot2/viewmodels/post_viewmodel.dart';
import 'package:the_shot2/views/market_screen.dart';
import 'package:the_shot2/viewmodels/market_viewmodel.dart';
import 'package:the_shot2/views/user_profile_screen.dart';


class BottomNavBar extends StatefulWidget {
  final int initialPage;

  const BottomNavBar({this.initialPage = 0, Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
        (_) => GlobalKey<NavigatorState>(),
  );

  final List<Widget> _screens = [
    HomeScreen(),
    const SearchScreen(),
    const PostScreen(),
    MarketScreen(viewModel: MarketViewModel(apiService: ApiService())),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) {
      // If already on tab, pop to first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_screens.length, (index) {
          return Navigator(
            key: _navigatorKeys[index],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => _screens[index],
              );
            },
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFCB7CCB),
        backgroundColor: Colors.grey[100],
        unselectedItemColor: Colors.grey[600],
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


