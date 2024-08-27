import 'package:flutter/material.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});


  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('文字编辑器屏幕'),
      );
    }
  }
