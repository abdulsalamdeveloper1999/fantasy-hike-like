import 'package:flutter/material.dart';
import 'package:step_journey/features/snore/presentation/pages/snore_recorder_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snore Recorder Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121B22),
      ),
      home: const SnoreRecorderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
