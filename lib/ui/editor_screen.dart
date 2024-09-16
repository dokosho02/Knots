import 'package:flutter/material.dart';
import 'package:frb_code/tools/fonts_tools.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});


  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    double fontSize = calculateFontSize(context);

    return Center(
        child: buildRichTextWithMaxLines(
          text: "文字编辑器 - EditorScreen",
          fontSize: fontSize,
        ),
      );
    }
  }
