import 'package:flutter/material.dart';
import 'package:refresh_view_example/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextDirection _textDirection = TextDirection.ltr;

  void _toggleDirection() {
    setState(() {
      _textDirection = _textDirection == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Directionality(
            textDirection: _textDirection,
            child: HomePage(onToggleDirection: _toggleDirection, textDirection: _textDirection),
          );
        },
      ),
    );
  }
}
