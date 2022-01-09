import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/pages/main_page.dart';
import 'package:memogenerator/resources/app_colors.dart';


void main() async {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(




      home: MainPage(),
    );
  }
}
