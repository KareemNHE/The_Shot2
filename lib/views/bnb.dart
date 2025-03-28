


//views/bnb.dart

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


class BottomNavBar extends StatefulWidget {
  const BottomNavBar();

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  List<Widget> pages = [
    HomeScreen(), // Pass the appropriate viewModel
    SearchScreen(viewModel: SearchViewModel(apiService: ApiService())), // Pass the appropriate viewModel
    PostScreen(), // Pass the appropriate viewModel
    MarketScreen(viewModel: MarketViewModel(apiService: ApiService())), // Pass the appropriate viewModel
    ProfileScreen(), // Pass the appropriate viewModel
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFCB7CCB),
        backgroundColor: Colors.grey[100],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        currentIndex: currentPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            activeIcon: Icon(Icons.add_a_photo_outlined),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            activeIcon: Icon(Icons.shopping_cart_outlined),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}
