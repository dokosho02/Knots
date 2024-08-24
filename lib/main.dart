import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:frb_code/src/rust/frb_generated.dart';
import 'package:frb_code/models/rss_provider.dart';

import 'package:frb_code/ui/home_screen.dart';
import 'package:frb_code/tools/folder_permission.dart';
import 'package:frb_code/tools/fonts_tools.dart';

void main() async {
  // 设置日志记录器
  Logger logger = Logger(
    level: Level.all,
    filter: null,
    printer: PrettyPrinter(),
    output: ConsoleOutput(),
  );

  logger.i('application started');
  
  WidgetsFlutterBinding.ensureInitialized();

  await loadFonts();
  adjustWindow();

  await RustLib.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => RssProvider(),
      child: const MyApp(),
    ),
  );
}

void adjustWindow() {
  
  if (isDesktop) {
    // Initialize window settings
    doWhenWindowReady(() {
      final window = appWindow;
      window.minSize = const Size(400, 400);
      window.alignment = Alignment.center;
      window.title = 'Read and Write';
  
      if (Platform.isLinux) {
        const channel = MethodChannel('flutter/platform');
        channel.invokeMethod('Window.setSize', {'width': 432, 'height': 768});
      } else {
        window.size = const Size(432, 768);
      }
  
      window.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Read and Write',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)
      home: const HomeScreen(),
    );
  }
}