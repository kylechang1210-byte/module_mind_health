import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'therapy_model.dart';
import 'therapy_page.dart';
import 'healing_music_page.dart';
import 'breathing_page.dart';
import 'movement_page.dart';

void main() {
  runApp(const MyApp());
}
//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // initialize the provider exactly
    return ChangeNotifierProvider(
      create: (context) => TherapyModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
        // Defining routes as per Practical 2
        initialRoute: '/',
        routes: {
          '/': (context) => const TherapyPage(),
          '/healing_music': (context) => const HealingMusicPage(),
          '/breathing': (context) => const BreathingPage(),
          '/movement': (context) => const MovementPage(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
