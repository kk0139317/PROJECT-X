import 'dart:ffi';

import 'package:flutter/material.dart';
import 'landing_screen.dart';
import 'upload_image_screen.dart';
import 'predictionscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classifier',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingScreen(),
        '/upload': (context) => UploadImageScreen(),
        '/prediction': (context) => PredictionsScreen(),
      },
    );
  }
}
