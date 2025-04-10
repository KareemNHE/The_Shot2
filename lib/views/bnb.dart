
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
  final String? userId; // optional

  const BottomNavBar({this.initialPage = 0, this.userId, Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int currentPageIndex;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    currentPageIndex = widget.initialPage;

    pages = [
      HomeScreen(),
      const SearchScreen(),
      const PostScreen(),
      MarketScreen(viewModel: MarketViewModel(apiService: ApiService())),
      const ProfileScreen(),
      widget.userId != null && widget.userId != FirebaseAuth.instance.currentUser?.uid
          ? UserProfileScreen(userId: widget.userId!)
          : const ProfileScreen(), // fallback to your own profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFCB7CCB),
        backgroundColor: Colors.grey[100],
        unselectedItemColor: Colors.grey[600],
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}

