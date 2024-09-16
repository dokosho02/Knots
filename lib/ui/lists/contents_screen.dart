// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/utils/scroll_area.dart';
import 'package:frb_code/ui/lists/utils/interactive_image.dart';
import 'package:frb_code/tools/fonts_tools.dart';

import 'package:frb_code/src/rust/api/simple.dart';
import 'package:frb_code/tools/folder_permission.dart';

import 'package:url_launcher/url_launcher.dart';



class ContentsScreen extends StatefulWidget {
  // final String url;
  // final String title;
  // final String publishedAt;

  const ContentsScreen({
    super.key,
    // required this.url,
    // required this.title,
    // required this.publishedAt,
  });

  @override
  ContentsScreenState createState() => ContentsScreenState();
}

class ContentsScreenState extends State<ContentsScreen> {
  final ScrollController _scrollController = ScrollController();

  late String currentItemLink;
  late String itemTitle;
  late String publishedAt;
  late String preText;

  @override
  void initState() {
    super.initState();
    fetchCurrentItemLink().then((_) {
      setState(() {
        // 任何其他初始化逻辑
      });
      _fetchContents(); // 现在你可以调用这个方法
    });
  }


  Future<void> fetchCurrentItemLink() async {
    final databaseName = await getFullDatabaseName();
    final currentLogDB = await getCurrentSettingsDatabaseName();
    currentItemLink = await fetchCurrentItemLinkAsync(dbPath: currentLogDB);
    itemTitle = await fetchItemTitleAsync(dbPath: databaseName, link: currentItemLink);
    publishedAt = await fetchPublishedAtAsync(dbPath: databaseName, link: currentItemLink);
    preText = '<h1>$itemTitle</h1>\n<p>$publishedAt</p>\n';
  }

  Future<String> _fetchContents() async {
    final rssProvider = Provider.of<RssProvider>(context, listen: false);
    final contents = await rssProvider.fetchContents(currentItemLink);
    return contents;
  }

  @override
  Widget build(BuildContext context) {
    // final rssProvider = Provider.of<RssProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    // const double contentPadding = 16.0;
    double contentPadding = screenWidth * 0.05;

    // const preText = '';

    double fontSize = calculateFontSize(context);
    // if (screenWidth < 500) {
    //   fontSize = 18;
    // } else if (screenWidth < 1000) {
    //   fontSize = 23;
    // } else {
    //   fontSize = 28;
    // }

    return FutureBuilder<void>(
      future: fetchCurrentItemLink(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading content: ${snapshot.error}'),
          );
        } else {
    return FutureBuilder<String>(
      future: _fetchContents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
                  appBar: AppBar(
                    title: const Text('Error loading content'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                    ),
                  ),
            body:
          Center(
            child: Text('Error loading content: ${snapshot.error}'),
          )
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
                  appBar: AppBar(
                    title: const Text('No content found'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                    ),
                  ),
            body:
          const Center(
            child: Text('No content found for this item.'),
          )
          );
        } else {
          final finalText = '$preText${snapshot.data!}';
          return Scaffold(
                  appBar: AppBar(
                    title: buildRichTextWithMaxLines(
                      text: itemTitle,
                      fontSize: fontSize,
                      ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                    ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      onPressed: () async {
                        final Uri url = Uri.parse(currentItemLink);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          print('Could not launch $currentItemLink');
                        }
                      },
                    ),
                  ],
                ),
              body: FocusScope(
                autofocus: true,
                child: Stack(
                  children: [
                    SelectionArea(
                      child: Padding(
                        padding: EdgeInsets.all(contentPadding),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: buildHtmlWidget(finalText, fontSize),
                        ),
                      ),
                    ),
                    ScrollArea(
                      scrollController: _scrollController,
                      contentPadding: contentPadding,
                    ),
                  ],
            ),
          ),
          );
        }
      },
    );
        }
      },
    );
  }

  Widget buildHtmlWidget(String htmlContent, double fontSize) {
    return HtmlWidget(
      htmlContent,
      textStyle: TextStyle(
        fontSize: fontSize,
      ),
      customWidgetBuilder: (element) {
        if (element.localName == 'img') {
          final imageUrl = element.attributes['src'];
          if (imageUrl != null) {
            return InteractiveImage(imageUrl: imageUrl);
          }
        }
        //  if (element.localName == 'a' && element.attributes.containsKey('href')) {
        //   final link = element.attributes['href']!;
        //   return Text.rich(
        //     TextSpan(
        //       text: element.text.trim(),
        //       // style: const TextStyle(
        //         // color: Colors.blue,
        //         // decoration: TextDecoration.underline,
        //       // ),
        //       recognizer: TapGestureRecognizer()
        //         ..onTap = () async {
        //           final Uri url = Uri.parse(link);
        //           if (await canLaunchUrl(url)) {
        //             await launchUrl(url);
        //           } else {
        //             print('Could not launch $link');
        //           }
        //         },
        //     ),
        //   );
          
        // }
        return null;
      },
      customStylesBuilder: (element) {
        if (element.localName == 'h1') {
          return {
            'font-size': '1.4em',
            'line-height': '1.1em',
          };
        }

        if (element.localName == 'a' && element.attributes.containsKey('href')) {
          return {
            'font-family': getElementFontFamily(element),
            // no underline
            'text-decoration': 'none',
          };
        }
        return {
          'white-space': element.localName == 'p' || element.localName == 'br' ? 'pre-wrap' : '',
          'font-family': getElementFontFamily(element),
        };
      },
      factoryBuilder: () => _CustomWidgetFactory(),
    );
  }
}

class _CustomWidgetFactory extends WidgetFactory {
  @override
  Widget? buildText(BuildTree tree, InheritedProperties inheritedProperties, InlineSpan span) {
    if (span is TextSpan) {
      return _buildSelectableRichText(span, inheritedProperties.prepareTextStyle());
    }
    return super.buildText(tree, inheritedProperties, span);
  }

  Widget _buildSelectableRichText(TextSpan span, TextStyle parentStyle) {
    List<InlineSpan> processedChildren = [];

    if (span.text != null) {
      processedChildren.addAll(styleTextByCharacter(span.text!, span.style ?? parentStyle));
    }

    if (span.children != null) {
      for (var child in span.children!) {
        if (child is TextSpan) {
          processedChildren.addAll(styleTextByCharacter(child.text ?? '', child.style ?? span.style ?? parentStyle));
        } else {
          processedChildren.add(child);
        }
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: span.style ?? parentStyle,
        children: processedChildren,
      ),
    );
  }
}


// 3

// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/utils/scroll_area.dart';
// import 'package:frb_code/ui/lists/utils/interactive_image.dart';
// import 'package:frb_code/tools/fonts_tools.dart';

// // import 'package:url_launcher/url_launcher.dart';

// class ContentsScreen extends StatefulWidget {
//   final String url;
//   final String title;
//   final String publishedAt;

//   const ContentsScreen({
//     super.key,
//     required this.url,
//     required this.title,
//     required this.publishedAt,
//     });

//   @override
//   ContentsScreenState createState() => ContentsScreenState();
// }

// class ContentsScreenState extends State<ContentsScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     final screenWidth = MediaQuery.of(context).size.width;

//     const double contentPadding = 16.0;

//     final preText  = '<h1>${widget.title}</h1>\n<p>${widget.publishedAt}</p>\n';

//     double fontSize;
//     if (screenWidth < 500) {
//       fontSize = 18;
//     } else if (screenWidth < 1000) {
//       fontSize = 23;
//     } else {
//       fontSize = 28;
//     }

//     return FutureBuilder<String>(
//       future: rssProvider.fetchContents(widget.url),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error loading content: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No content found for this item.'),
//           );
//         } else {
//           final finalText = '$preText${snapshot.data!}';
// return Scaffold(
//   body: Stack(
//     children: [
//       SelectionArea(
//         child: Padding(
//           padding: const EdgeInsets.all(contentPadding),
//           child: SingleChildScrollView(
//             controller: _scrollController,
//             child: HtmlWidget(
//               // snapshot.data!,
//               finalText,
//               textStyle: TextStyle(
//                 fontSize: fontSize,
//               ),
//                 // onTapUrl: (url) async {
//                 //   await launchUrl(Uri.parse(url));
//                 //   return true;
//                 // },
//               customWidgetBuilder: (element) {
//                 // if (element.localName == 'a' && element.attributes.containsKey('href')) {
//                 //   final url = element.attributes['href']!;
//                 //   return GestureDetector(
//                 //     onTap: () async {
//                 //       final Uri uri = Uri.parse(url);
//                 //       if (await canLaunchUrl(uri)) {
//                 //         await launchUrl(uri);
//                 //       } else {
//                 //         print('Could not launch $url');
//                 //       }
//                 //     },
//                     // child: null,
//                     // Text(
//                     //   element.text,
//                     //   style: const TextStyle(
//                     //     color: Colors.blue,
//                     //     decoration: TextDecoration.underline,
//                     //   ),
//                     // ),
//                   // );
//                 // }
//                 if (element.localName == 'img') {
//                   final imageUrl = element.attributes['src'];
//                   if (imageUrl != null) {
//                     return InteractiveImage(imageUrl: imageUrl);
//                   }
//                 }
//                 return null;
//               },
//               customStylesBuilder: (element) {
//                 if (element.localName == 'h1') {
//                   return {
//                     'font-size': '1.6em',
//                     'line-height': '1.1em',
//                   };
//                 }

//                 if (element.localName == 'a' && element.attributes.containsKey('href')) {
//                   return {
//                     // 'color': 'blue',
//                     // 'text-decoration': 'underline',
//                   'font-family': getElementFontFamily(element),
//                   };
//                 }
//                 return {
//                   'white-space': element.localName == 'p' || element.localName == 'br' ? 'pre-wrap' : '',
//                   'font-family': getElementFontFamily(element),
//                 };
//               },
//               factoryBuilder: () => _CustomWidgetFactory(),
//             ),
//           ),
//         ),
//       ),
//       ScrollArea(
//         scrollController: _scrollController,
//         contentPadding: contentPadding,
//       ),
//     ],
//   ),
// );
//         }
//       },
//     );
//   }
// }

// class _CustomWidgetFactory extends WidgetFactory {
//   @override
//   Widget? buildText(BuildTree tree, InheritedProperties inheritedProperties, InlineSpan span) {
//     if (span is TextSpan) {
//       return _buildSelectableRichText(span, inheritedProperties.style);
//     }
//     return super.buildText(tree, inheritedProperties, span);
//   }

//   Widget _buildSelectableRichText(TextSpan span, TextStyle? parentStyle) {
//     List<InlineSpan> processedChildren = [];

//     if (span.text != null) {
//       processedChildren.addAll(styleTextByCharacter(span.text!, span.style ?? parentStyle));
//     }

//     if (span.children != null) {
//       for (var child in span.children!) {
//         if (child is TextSpan) {
//           processedChildren.addAll(styleTextByCharacter(child.text ?? '', child.style ?? span.style ?? parentStyle));
//         } else {
//           processedChildren.add(child);
//         }
//       }
//     }

//     return SelectableText.rich(
//       TextSpan(
//         style: span.style ?? parentStyle,
//         children: processedChildren,
//       ),
//     );
//   }
// }

// 2

// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/utils/scroll_area.dart';
// import 'package:frb_code/ui/lists/utils/interactive_image.dart';
// import 'package:html/dom.dart' as dom;
// import 'package:frb_code/tools/utils.dart';

// class ContentsScreen extends StatefulWidget {
//   final String url;
//   final String title;

//   const ContentsScreen({super.key, required this.url, required this.title});

//   @override
//   ContentsScreenState createState() => ContentsScreenState();
// }

// class ContentsScreenState extends State<ContentsScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     final screenWidth = MediaQuery.of(context).size.width;

//     const double contentPadding = 16.0;

//     double fontSize;
//     if (screenWidth < 500) {
//       fontSize = 18;
//     } else if (screenWidth < 800) {
//       fontSize = 22;
//     } else {
//       fontSize = 24;
//     }

//     return FutureBuilder<String>(
//       future: rssProvider.fetchContents(widget.url),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error loading content: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No content found for this item.'),
//           );
//         } else {
//           return Scaffold(
//             body: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(contentPadding),
//                   child: SingleChildScrollView(
//                     controller: _scrollController,
//                     child: SelectionArea(
//                       child: HtmlWidget(
//                         snapshot.data!,
//                         textStyle: TextStyle(
//                           fontSize: fontSize,
//                         ),
//                         customWidgetBuilder: (element) {
//                           if (element.localName == 'img') {
//                             final imageUrl = element.attributes['src'];
//                             if (imageUrl != null) {
//                               return InteractiveImage(imageUrl: imageUrl);
//                             }
//                           }
//                           return null;
//                         },
//                         customStylesBuilder: (element) {
//                           final isChinese = containsChineseCharacters(element);
//                           return {
//                             'font-family': isChinese ? zhFont : engFont,
//                             'white-space': element.localName == 'p' || element.localName == 'br' ? 'pre-wrap' : '',
//                           };
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 ScrollArea(
//                   scrollController: _scrollController,
//                   contentPadding: contentPadding,
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }

//   bool containsChineseCharacters(dom.Element element) {
//     if (element.nodes.isEmpty) return false;

//     for (var node in element.nodes) {
//       if (node is dom.Text && RegExp(r'[\u4e00-\u9fff]').hasMatch(node.text)) {
//         return true;
//       }
//     }
//     return false;
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/utils/scroll_area.dart';
// import 'package:frb_code/ui/lists/utils/interactive_image.dart';


// class ContentsScreen extends StatefulWidget {
//   final String url;
//   final String title;

//   const ContentsScreen({super.key, required this.url, required this.title});

//   @override
//   ContentsScreenState createState() => ContentsScreenState();
// }

// class ContentsScreenState extends State<ContentsScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     final screenWidth = MediaQuery.of(context).size.width;

//     const double contentPadding = 16.0;

//     double fontSize;
//     if (screenWidth < 500) {
//       fontSize = 18;
//     } else if (screenWidth < 800) {
//       fontSize = 22;
//     } else {
//       fontSize = 24;
//     }

//     return FutureBuilder<String>(
//       future: rssProvider.fetchContents(widget.url),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error loading content: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No content found for this item.'),
//           );
//         } else {
//           return Scaffold(
//             body: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(contentPadding),
//                   child: SingleChildScrollView(
//                     controller: _scrollController,
//                     child: SelectionArea(
//                       child: HtmlWidget(
//                         snapshot.data!,
//                         textStyle: TextStyle(
//                           fontSize: fontSize,
//                         ),
//                         customWidgetBuilder: (element) {
//                           if (element.localName == 'img') {
//                             final imageUrl = element.attributes['src'];
//                             if (imageUrl != null) {
//                               return InteractiveImage(imageUrl: imageUrl);
//                             }
//                           }
//                           return null;
//                         },
//                         customStylesBuilder: (element) {
//                           if (element.localName == 'p' || element.localName == 'br') {
//                             return {
//                               'white-space': 'pre-wrap',
//                             };
//                           }
//                           return {};
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 ScrollArea(
//                   scrollController: _scrollController,
//                   contentPadding: contentPadding,
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }

