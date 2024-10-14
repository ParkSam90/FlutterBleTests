import 'dart:async';
import 'dart:developer';

import 'package:bluetooth_low_energy_android_example/spalsh.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() {
  runZonedGuarded(onStartUp, onCrashed);
}

void onStartUp() async {
  Logger.root.onRecord.listen(onLogRecord);
  hierarchicalLoggingEnabled = true;
  runApp(const MyApp());
}

void onCrashed(Object error, StackTrace stackTrace) {
  Logger.root.shout('App crached.', error, stackTrace);
}

void onLogRecord(LogRecord record) {
  log(
    record.message,
    time: record.time,
    sequenceNumber: record.sequenceNumber,
    level: record.level.value,
    name: record.loggerName,
    zone: record.zone,
    error: record.error,
    stackTrace: record.stackTrace,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mCandle Server App',
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: Splash(),
      // routerConfig: routerConfig,
      // theme: ThemeData.light().copyWith(
      //   materialTapTargetSize: MaterialTapTargetSize.padded,
      // ),
      // darkTheme: ThemeData.dark().copyWith(
      //   materialTapTargetSize: MaterialTapTargetSize.padded,
      // ),
    );
  }
}
