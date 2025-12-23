import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseConnection {
  static const String _supabaseUrl =
      'https://fkjjrvrffecgctsgaeqv.supabase.co';
  static const String _supabaseKey =
      'sb_secret_G9pnhzBS1qjLlgQs5LV1DA_z4ZSOr3Q';


  // Call this ONCE in main()
  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseKey,
    );
  }


  // Global client you can use anywhere
  static SupabaseClient get client => Supabase.instance.client;
}
