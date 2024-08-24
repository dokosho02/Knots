// import 'package:html/dom.dart' as dom;

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import 'package:frb_code/tools/folder_permission.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart';

const zhFont = 'LXGWWenKai';
const engFont = 'Ubuntu';


  String getElementFontFamily(dom.Element element) {
    if (containsMixedLanguages(element.text)) {
      return 'mixed'; // 我们将使用自定义样式处理混合语言
    }
    return containsCJKCharacters(element.text) ? zhFont : engFont;
  }

  bool containsCJKCharacters(String text) {
      // final cRegex = RegExp(r'[\u4e00-\u9fff\u3040-\u309F\u30A0-\u30FF]');
      final cRegex = RegExp(r'[\u4e00-\u9fff\u3040-\u309F\u30A0-\u30FF\uAC00-\uD7AF]');
      return cRegex.hasMatch(text);
    // return RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
  }

  bool containsMixedLanguages(String text) {
    bool hasChineseOrJapanese = containsCJKCharacters(text);
    bool hasNonChinese = RegExp(r'[a-zA-Z]').hasMatch(text);
    return hasChineseOrJapanese && hasNonChinese;
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

  List<InlineSpan> processText(String text, TextStyle? style) {
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