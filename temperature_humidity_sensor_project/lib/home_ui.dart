import 'package:flutter/material.dart';

class HomeUI extends StatefulWidget {
  final double temperature;
  final double humidity;
  const HomeUI({Key? key, required this.temperature, required this.humidity}) : super(key: key);
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
              ),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.black)),
                width: double.infinity,
                child: Column(
                  children: [
                    Text('${widget.temperature.toDouble()}°C Degree', style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
