
//search_screen.dart

import '../viewmodels/search_viewmodel.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {

  final SearchViewModel viewModel;

  const SearchScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Text('Explore!'),
      ),

    );
  }
}
