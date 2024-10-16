import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final int rssiThreshold;
  final int scanDuration;

  SettingsScreen({
    required this.rssiThreshold,
    required this.scanDuration,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _rssiController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _rssiController =
        TextEditingController(text: widget.rssiThreshold.toString());
    _durationController =
        TextEditingController(text: widget.scanDuration.toString());
  }

  @override
  void dispose() {
    _rssiController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    Navigator.pop(context, {
      'rssiThreshold': int.parse(_rssiController.text),
      'scanDuration': int.parse(_durationController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rssiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'RSSI Threshold',
              ),
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Scanning Duration (초)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
