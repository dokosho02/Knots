import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'package:frb_code/tools/folder_permission.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart';

const zhFont = 'LXGWWenKai';
const engFont = 'Ubuntu';


// double appFontSize;

Color setTextColorByThemeMode(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return isDarkMode ? Colors.white : Colors.black;
}


Widget buildRichTextWithMaxLines({
  required String text,
  required double fontSize,
  int maxLines = 1,
  String ellipsis = '...',
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final textColor = setTextColorByThemeMode(context); // 调用独立函数获取文本颜色
      final span = TextSpan(
        children: styleTextByCharacter(
          text,
          TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      );

      // 创建 TextPainter 来处理文本布局
      final painter = TextPainter(
        text: span,
        maxLines: maxLines, // 设置最大行数
        ellipsis: ellipsis, // 处理溢出的文本
        textDirection: TextDirection.ltr, // 设置文本方向
      );

      // 设置宽度约束
      painter.layout(maxWidth: constraints.maxWidth);

      return RichText(
        text: span,
        maxLines: maxLines, // 显示最多指定行数
        overflow: TextOverflow.ellipsis, // 设置文本溢出为省略号
      );
    },
  );
}



String getElementFontFamily(dom.Element element) {
  if (containsMixedLanguages(element.text)) {
    return 'mixed'; // 我们将使用自定义样式处理混合语言
  }
  return containsCJKCharacters(element.text) ? zhFont : engFont;
}

bool containsCJKCharacters(String text) {
    final cRegex = RegExp(r'[\u4e00-\u9fff\u3040-\u309F\u30A0-\u30FF\uAC00-\uD7AF]');
    return cRegex.hasMatch(text);
}

bool containsMixedLanguages(String text) {
  bool hasCJK = containsCJKCharacters(text);
  bool hasNonChinese = RegExp(r'[a-zA-Z]').hasMatch(text);
  return hasCJK && hasNonChinese;
}



List<InlineSpan> styleTextByCharacter(String text, TextStyle? style) {
  List<InlineSpan> spans = [];
  // final mixedRegex = RegExp(r'([\u4e00-\u9fff]+)|([a-zA-Z0-9\s]+)');
  // final mixedRegex = RegExp(r'([\u4e00-\u9fff]+)|([a-zA-Z0-9\s]+)', unicode: true);
//     final mixedRegex = RegExp(
//   r'([\u4e00-\u9fff\u3040-\u309F\u30A0-\u30FF]+)|([a-zA-Z0-9\s]+)',
//   unicode: true,
// );
  final mixedRegex = RegExp(
  r'([\u4e00-\u9fff\u3040-\u309F\u30A0-\u30FF\uAC00-\uD7AF]+)|([a-zA-Z0-9\s]+)',
  unicode: true,
  );

  final matches = mixedRegex.allMatches(text);

  int lastEnd = 0;
  for (var match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: style,
      ));
    }

    final matchedText = match.group(0)!;
    final isChinese = match.group(1) != null;

    spans.add(TextSpan(
      text: matchedText,
      style: style?.copyWith(
        fontFamily: isChinese ? zhFont : engFont,
      ),
    ));

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: style,
    ));
  }

  return spans;
}




double calculateFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double fontSize;
    if (screenWidth < 450) {
      fontSize = 18;
    } else if (screenWidth < 900) {
      fontSize = 23;
    } else {
      fontSize = 28;
    }

    return fontSize;
}




Future<void> loadFonts() async {

  await requestStoragePermission();

  final rootFolder = await getFolder();
  final fontDirectory = join(rootFolder, 'fonts');

  await CustomFontLoader.loadFont('Ubuntu', [
    '$fontDirectory/Ubuntu-Regular.ttf',
    '$fontDirectory/Ubuntu-Bold.ttf',
    '$fontDirectory/Ubuntu-Italic.ttf',
  ]);

  await CustomFontLoader.loadFont('LXGWWenKai', [
    '$fontDirectory/LXGWWenKai-Regular.ttf',
    '$fontDirectory/LXGWWenKai-Bold.ttf',
    '$fontDirectory/LXGWWenKai-light.ttf',
  ]);
}

class CustomFontLoader {
  static Future<void> loadFont(String fontFamily, List<String> fontPaths) async {
    final loader = FontLoader(fontFamily);
    for (final path in fontPaths) {
      final file = File(path);
      if (await file.exists()) {
        final fontData = await file.readAsBytes();
        loader.addFont(Future.value(ByteData.view(fontData.buffer)));
      } else {
        print('Font file not found: $path');
      }
    }
    await loader.load();
  }
}
