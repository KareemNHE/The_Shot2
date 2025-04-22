
import 'package:flutter/material.dart';
import '../viewmodels/market_viewmodel.dart';

class MarketScreen extends StatefulWidget {

  final MarketViewModel viewModel;

  const MarketScreen({Key? key, required this.viewModel}) : super(key: key);


  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market'),
      ),
      body: Center(
        child: Text('Advertise here!'),
      ),

    );
  }
}
