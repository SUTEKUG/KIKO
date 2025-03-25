import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:owner/screens/auth/owner_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://umajdgzwhlxibiomndpy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtYWpkZ3p3aGx4aWJpb21uZHB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1NzUyOTksImV4cCI6MjA1MTE1MTI5OX0.AriM962NS5ZWYU1hyRWTgvsiBatZf5GngDTY0eg4rkA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      debugShowCheckedModeBanner: false,
      home: OwnerLoginScreen(),
    );
  }
}
