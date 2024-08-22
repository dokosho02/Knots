import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool showLabels;
  final ValueChanged<bool> onToggleLabels;

  const SettingsScreen({
    super.key,
    required this.showLabels,
    required this.onToggleLabels,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late bool _showLabels;

  @override
  void initState() {
    super.initState();
    _showLabels = widget.showLabels;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onToggleLabels(_showLabels);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Center(
          child: ListTile(
            title: const Text('Show BottomNavigationBar Labels'),
            trailing: Switch(
              value: _showLabels,
              onChanged: (value) {
                setState(() {
                  _showLabels = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}