/// lib/views/settings_page.dart
/// VIEW: Settings page. Allows theme switching and font size, accent color.
/// Settings persisted using SharedPreferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  double _fontSize = 16;
  int _accentIndex = 0;
  final List<MaterialColor> accents = [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink];

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
      _accentIndex = prefs.getInt('accentIndex') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setInt('accentIndex', _accentIndex);
    // Indicate to caller that settings changed so UI can refresh if needed
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            const SizedBox(height: 8),
            Text('Font size: ${_fontSize.toStringAsFixed(0)}'),
            Slider(min: 12, max: 24, value: _fontSize, onChanged: (v) => setState(() => _fontSize = v)),
            const SizedBox(height: 8),
            const Text('Accent color'),
            Wrap(
              spacing: 8,
              children: List.generate(accents.length, (i) {
                return ChoiceChip(
                  label: Text(accents[i].toString().split('(0x')[0].replaceAll('MaterialColor', '').trim()),
                  selected: _accentIndex == i,
                  onSelected: (_) => setState(() => _accentIndex = i),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text('Save settings')),
          ],
        ),
      ),
    );
  }
}
