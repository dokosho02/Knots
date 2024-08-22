import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/scroll_area.dart';

class ContentsScreen extends StatefulWidget {
  final String url;
  final String title;

  const ContentsScreen({super.key, required this.url, required this.title});

  @override
  ContentsScreenState createState() => ContentsScreenState();
}

class ContentsScreenState extends State<ContentsScreen> {
  final ScrollController _scrollController = ScrollController();
  // final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

// 定义内容的 padding 和 gestureDetector 的尺寸
    const double contentPadding = 16.0;

    // 根据屏幕宽度定义字体大小
    double fontSize;
    if (screenWidth < 500) {
      fontSize = 18; // 小屏幕设备
    } else if (screenWidth < 800) {
      fontSize = 22; // 中等屏幕设备
    } else {
      fontSize = 24; // 大屏幕设备
    }

    return FutureBuilder<String>(
        future: rssProvider.fetchContents(widget.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading content: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No content found for this item.'),
            );
          } else {


return Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(contentPadding),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SelectionArea(
                      child: HtmlWidget(
                        snapshot.data!,
                        textStyle: TextStyle(
                          fontSize: fontSize,
                        ),
                        customStylesBuilder: (element) {
                          if (element.localName == 'p' || element.localName == 'br') {
                            return {
                              'white-space': 'pre-wrap',
                            };
                          }
                          return {};
                        },
                      ),
                    ),
                  ),
                ),
                ScrollArea(
                  scrollController: _scrollController,
                  contentPadding: contentPadding,
                  // onScrollUp: () => _scrollController.scrollPage(context, ScrollDirection.up),
                  // onScrollDown: () => _scrollController.scrollPage(context, ScrollDirection.down),
                ),
              ],
            ),
          );
    //     }
    //   },
    // );



    //       return Scaffold(
    //   body: Stack(
    //     children: [
    //       GestureDetector(
    //         // onDoubleTap: () => _scrollPage(context, ScrollDirection.down),
    //         child: Padding(
    //           padding: const EdgeInsets.all(contentPadding),
    //           child: SingleChildScrollView(
    //             controller: _scrollController,
    //             child: SelectionArea(
    //               // child: Padding(
    //               //   padding: const EdgeInsets.all(16.0),
    //                 child: HtmlWidget(
    //                   snapshot.data!,
    //                   textStyle: TextStyle(
    //                     fontSize: fontSize,
    //                   ),
    //                   customStylesBuilder: (element) {
    //                     if (element.localName == 'p' || element.localName == 'br') {
    //                       return {
    //                         'white-space': 'pre-wrap',
    //                       };
    //                     }
    //                     return {};
    //                   },
    //                 // ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         top: 0,
    //         left: 0,
    //         right: screenWidth - contentPadding,
    //         height: screenHeight / 2,
    //         child: GestureDetector(
    //           onTap: () => _scrollPage(context, ScrollDirection.up),
    //           child: Container(
    //             color: Colors.transparent,
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         bottom: 0,
    //         left: 0,
    //         right: screenWidth - contentPadding,
    //         height: screenHeight / 2,
    //         child: GestureDetector(
    //           onTap: () => _scrollPage(context, ScrollDirection.down),
    //           child: Container(
    //             color: Colors.transparent,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
          }
        },
    );
  }

  // void _scrollPage(BuildContext context, ScrollDirection direction) {
  //   final double scrollHeight = MediaQuery.of(context).size.height*0.85;
  //   final double maxScrollExtent = _scrollController.position.maxScrollExtent;
  //   final double minScrollExtent = _scrollController.position.minScrollExtent;
  //   final double currentOffset = _scrollController.offset;

  //   // 计算新的偏移量
  //   final double offsetChange = direction == ScrollDirection.down
  //       ? scrollHeight
  //       : -scrollHeight;
  //   final double newOffset = currentOffset + offsetChange;

  //   // 判断是否到底或到顶
  //   if (direction == ScrollDirection.down && currentOffset >= maxScrollExtent) {
  //     return; // 到达底部，无法向下滚动
  //   } else if (direction == ScrollDirection.up && currentOffset <= minScrollExtent) {
  //     return; // 到达顶部，无法向上滚动
  //   }

  //   // 执行滚动
  //   _scrollController.jumpTo(newOffset);
  // }
}

// enum ScrollDirection { up, down }



// 3

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:frb_code/models/rss_provider.dart';

// class ContentsScreen extends StatelessWidget {
//   final String url;
//   final String title;

//   const ContentsScreen({super.key, required this.url, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     final screenWidth = MediaQuery.of(context).size.width;

//     // 根据屏幕宽度定义字体大小
//     double fontSize;
//     if (screenWidth < 450) {
//       fontSize = 18; // 小屏幕设备
//     } else if (screenWidth < 800) {
//       fontSize = 22; // 中等屏幕设备
//     } else {
//       fontSize = 24; // 大屏幕设备
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: FutureBuilder<String>(
//         future: rssProvider.fetchContents(url),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error loading content: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text('No content found for this item.'),
//             );
//           } else {
//             return SelectionArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: HtmlWidget(
//                     snapshot.data!,
//                     textStyle: TextStyle(
//                       fontSize: fontSize,
//                     ),
//                     customStylesBuilder: (element) {
//                       if (element.localName == 'p') {
//                         return {
//                           'text-align': 'justify',
//                           'user-select': 'text',
//                         };
//                       }
//                       return {};
//                     },
//                   ),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }


// 2

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:frb_code/models/rss_provider.dart';

// class ContentsScreen extends StatelessWidget {
//   final String url;
//   final String title;

//   const ContentsScreen({super.key, required this.url, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: FutureBuilder<String>(
//         future: rssProvider.fetchContents(url),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error loading content: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text('No content found for this item.'),
//             );
//           } else {
//             return SelectionArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: HtmlWidget(
//                     snapshot.data!,
//                     textStyle: const TextStyle(
//                       fontSize: 16,
//                       // color: Colors.yellow,  // 设置文本颜色
//                     ),
//                     customStylesBuilder: (element) {
//                       if (element.localName == 'p') {
//                         return {
//                           'text-align': 'justify',  // 使段落文本对齐
//                           'user-select': 'text',  // 确保文本可选
//                         };
//                       }
//                       return {};
//                     },
//                   ),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }



// 1

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';

// class ContentsScreen extends StatelessWidget {
//   final String url;
//   final String title;

//   const ContentsScreen({super.key, required this.url, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: FutureBuilder<String>(
//         future: rssProvider.fetchContents(url),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error loading content: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text('No content found for this item.'),
//             );
//           } else {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: SelectableText(
//                   snapshot.data!,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
