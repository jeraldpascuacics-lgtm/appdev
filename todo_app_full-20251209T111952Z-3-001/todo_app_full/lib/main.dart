/// lib/main.dart
/// App bootstrap. Loads persisted settings and applies theme.
/// MVC: Views call Controller methods which operate on Model & DB.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  bool _darkMode = false;
  double _fontSize = 16;
  MaterialColor _accent = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16;
      final idx = prefs.getInt('accentIndex') ?? 0;
      final accents = [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink];
      _accent = accents[idx];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      primarySwatch: _accent,
      textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: _fontSize / 16.0),
    );
    return MaterialApp(
      title: 'To-Do MVC Complete',
      theme: theme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
