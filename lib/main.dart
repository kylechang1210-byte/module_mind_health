import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supabase_connection.dart';
import 'therapy_model.dart';
import 'auth_screens.dart'; // Handles the initial Login check

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase Connection
  await SupabaseConnection.init();

  runApp(
    // 2. Setup Global State Provider (for Therapy Sessions)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TherapyModel()),
      ],
      child: const MindHealthApp(),
    ),
  );
}

class MindHealthApp extends StatelessWidget {
  const MindHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Health Integrated',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C9DFF)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5C9DFF),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // 3. Start at AuthGate to check if user is logged in
      home: const AuthGate(),
    );
  }
}