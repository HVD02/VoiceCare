import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://acakceautcsimbayhrkp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjYWtjZWF1dGNzaW1iYXlocmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNzg5NzEsImV4cCI6MjA3Nzc1NDk3MX0.jQKiDxVT3a9L4XvhLBZk33lSXCFgPq3SVTQak_Apd1o',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SupabaseCheck(),
    );
  }
}

class SupabaseCheck extends StatefulWidget {
  const SupabaseCheck({super.key});

  @override
  State<SupabaseCheck> createState() => _SupabaseCheckState();
}

class _SupabaseCheckState extends State<SupabaseCheck> {
  String _status = "Checking Supabase connection...";

  @override
  void initState() {
    super.initState();
    _checkSupabaseConnection();
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      final response = await Supabase.instance.client
          .from('test')
          .select()
          .limit(1);
      setState(() => _status = "✅ Supabase connected successfully!");
    } catch (e) {
      setState(() => _status = "❌ Supabase connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _status,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}