import 'dart:ui';

import 'package:dart_vader/dart_vader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/weather_img.jpg'), fit: BoxFit.cover)),
        child: Center(
          child: Column(
            children: [
              context.spacerWithFlex(flex: 1),
              Expanded(child: _conditionsOfPlaceText()),
              Expanded(child: _nowText()),
              Expanded(flex: 2, child: _tempRow(context)),
              Expanded(flex: 2, child: _humidityRow()),
              context.spacerWithFlex(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nowText() => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenWidht * 0.3),
        child: FittedBox(
          child: Text(
            '${DateFormat("yMd").format(DateTime.now())}',
            style: context.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: context.fontWeightBold,
            ),
          ),
        ),
      );

  Widget _humidityRow() => Padding(
        padding: context.symmetricPaddingLow,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.3),
              child: Row(
                children: [
                  context.spacerWithFlex(flex: 1),
                  Expanded(flex: 3, child: Lottie.asset('assets/humidity.json')),
                  context.spacerWithFlex(flex: 1),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        ' %${widget.humidity.toDouble()}',
                        style: context.appTextTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: context.fontWeightBold,
                        ),
                      ),
                    ),
                  ),
                  context.spacerWithFlex(flex: 1),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _tempRow(BuildContext context) {
    return Padding(
      padding: context.symmetricPaddingLow,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.white.withOpacity(0.3),
            child: Row(
              children: [
                context.spacerWithFlex(flex: 1),
                Expanded(flex: 3, child: Lottie.asset('assets/weather.json')),
                context.spacerWithFlex(flex: 1),
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    child: Text(
                      '${widget.temperature.toDouble()}°C',
                      style: context.appTextTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: context.fontWeightBold,
                      ),
                    ),
                  ),
                ),
                context.spacerWithFlex(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _conditionsOfPlaceText() => Padding(
        padding: context.symmetricPaddingMedium,
        child: FittedBox(
          child: Text(
            'Conditions of the Place',
            style: GoogleFonts.pacifico(fontSize: 30, color: Colors.white),
          ),
        ),
      );
}
