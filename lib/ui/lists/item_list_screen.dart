import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/home_scaffold.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:frb_code/ui/lists/contents_screen.dart';
import 'package:frb_code/ui/lists/utils/scroll_area.dart';
import 'package:frb_code/src/rust/api/simple.dart';

class ItemListScreen extends StatefulWidget {
  final String feedUrl;

  const ItemListScreen({super.key, required this.feedUrl});

  @override
  ItemListScreenState createState() => ItemListScreenState();
}

class ItemListScreenState extends State<ItemListScreen> {
  late Future<void> _fetchItemsFuture;
  late ScrollController _scrollController;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchItemsFuture = _fetchItems();
    _scrollController = ScrollController();
  }

  Future<void> _fetchItems() async {
    final rssProvider = Provider.of<RssProvider>(context, listen: false);
    await rssProvider.fetchItems(widget.feedUrl);
  }

  Future<String> calculateRelativeTime(String utcTimeStr) async {
    try {
      final String relativeTime = await getRelativeTime(utcTimeStr: utcTimeStr);
      return relativeTime;
    } catch (e) {
      // _logger.e('Error calculating relative time', e);
      return "";
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildListTile(double screenWidth, String title, String? publishedAt, Widget? leadingWidget) {
    return ListTile(
      // contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      title: Row(
        children: [
          leadingWidget ?? const SizedBox.shrink(), // 如果没有 leadingWidget，就不显示任何内容
          if (publishedAt != null)
            SizedBox(
              width: screenWidth*0.055,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  publishedAt,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
                      ),

          // add a space between the time and the title
          if (publishedAt != null)
            const SizedBox(width: 8.0),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ],
      ),
      onTap: () {
        // 导航到 ContentsScreen 并传递链接
        final rssProvider = Provider.of<RssProvider>(context, listen: false);
        final item = rssProvider.items.firstWhere((element) => element['title'] == title);
        final url = item['link'];
        if (url != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScaffold(
                body: ContentsScreen(
                  url: url,
                  title: item['title'] ?? 'No title',
                  publishedAt: item['time'] ?? 'No time',
                ),
                selectedIndex: 1, // Ensure this matches the index for RssScreen
                showLabels: true, // Adjust based on your needs
                bookScreenKey: GlobalKey<BookScreenState>(),
                rssScreenKey: GlobalKey<RssScreenState>(),
                toggleLabels: (value) {
                  // Handle label toggling if needed
                },
                appBarTitle: item['title'] ?? 'No title',
              ),
            ),
          );
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context);
    const paddingValue = 16.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _fetchItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildListTile(
                  screenWidth,
                  'Loading...',
                  null,
                  const CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return _buildListTile(
                  screenWidth,
                  'Error',
                  null,
                  const Text('Error', style: TextStyle(color: Colors.red)),
                );
              } else {
                final items = rssProvider.items;

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items found for this feed.'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = item['title'] ?? 'No title';
                    final timeStr = item['time'] ?? 'No time';
                    _logger.i('timeStr: $timeStr');

                    return FutureBuilder<String>(
                      future: calculateRelativeTime(timeStr),
                      builder: (context, snapshot) {
                        final publishedAt = snapshot.data ?? '';
                        return _buildListTile(
                          screenWidth,
                          title,
                          publishedAt,
                          null,
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
          ScrollArea(
            scrollController: _scrollController,
            contentPadding: paddingValue,
          ),
        ],
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/lists/contents_screen.dart';
// import 'package:frb_code/ui/lists/utils/scroll_area.dart';
// import 'package:frb_code/src/rust/api/simple.dart';

// class ItemListScreen extends StatefulWidget {
//   final String feedUrl;

//   const ItemListScreen({super.key, required this.feedUrl});

//   @override
//   ItemListScreenState createState() => ItemListScreenState();
// }

// class ItemListScreenState extends State<ItemListScreen> {
//   late Future<void> _fetchItemsFuture;
//   late ScrollController _scrollController;
//   final Logger _logger = Logger();

//   @override
//   void initState() {
//     super.initState();
//     _fetchItemsFuture = _fetchItems();
//     _scrollController = ScrollController();
//   }

//   Future<void> _fetchItems() async {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     await rssProvider.fetchItems(widget.feedUrl);
//   }


//   Future<String> calculateRelativeTime(String utcTimeStr) async {
//     try {
//       // 调用 Rust 异步函数
//       final String relativeTime = await getRelativeTime(utcTimeStr: utcTimeStr);
//       return relativeTime;
//     } catch (e) {
//       return "";
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context);
//     const paddingValue = 16.0;
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: paddingValue), // 设置左右 padding
//           // child: 
//           FutureBuilder<void>(
//             future: _fetchItemsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text('Error loading items: ${snapshot.error}'),
//                 );
//               } else {
//                 final items = rssProvider.items;

//                 if (items.isEmpty) {
//                   return const Center(
//                     child: Text('No items found for this feed.'),
//                   );
//                 }

//                 return ListView.builder(
//                   controller: _scrollController, // 使用 ScrollController
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     final title = item['title'] ?? 'No title';
//                     final timeStr = item['time'] ?? 'No time';
//                     _logger.i('timeStr: $timeStr');
//                     // final publishedAt = calculateRelativetime(timeStr);
//                     // 使用 FutureBuilder 来处理每一项的时间计算
//                     return FutureBuilder<String>(
//                       future: calculateRelativeTime(timeStr),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return ListTile(
//                             contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                             title: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   child: const CircularProgressIndicator(),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     title,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else if (snapshot.hasError) {
//                           return ListTile(
//                             contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                             title: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   child: const Text('Error', style: TextStyle(color: Colors.red)),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     title,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           final publishedAt = snapshot.data ?? '';
//                           _logger.i('publishedAt: $publishedAt');
//                           return ListTile(
//                               contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                               title: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.only(right: 8.0),
//                                     child: Text(
//                                       publishedAt,
//                                       style: const TextStyle(
//                                         fontSize: 12.0,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       title,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 final url = item['link'];
//                                 if (url != null) {
//                                   // 导航到 ContentsScreen 并传递链接
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => HomeScaffold(
//                                         body: ContentsScreen(
//                                           url: url,
//                                           title: item['title'] ?? 'No title',
//                                           publishedAt: item['time'] ?? 'No time',
//                                         ),
//                                         selectedIndex: 1, // Ensure this matches the index for RssScreen
//                                         showLabels: true, // Adjust based on your needs
//                                         bookScreenKey: GlobalKey<BookScreenState>(),
//                                         rssScreenKey: GlobalKey<RssScreenState>(),
//                                         toggleLabels: (value) {
//                                           // Handle label toggling if needed
//                                         },
//                                         appBarTitle: item['title'] ?? 'No title',
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                             );
//                           }
//                         },
//                       );
//                   },
//                 );
//               }
//             },
//           ),
//           // ),
//           ScrollArea(
//             scrollController: _scrollController,
//             contentPadding: paddingValue, // 设置适当的 padding
//           ),
//         ],
//       ),
//     );
//   }
// }



// 2

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';

// import 'package:frb_code/ui/lists/contents_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';

// class ItemListScreen extends StatefulWidget {
//   final String feedUrl;

//   const ItemListScreen({super.key, required this.feedUrl});

//   @override
//   ItemListScreenState createState() => ItemListScreenState();
// }

// class ItemListScreenState extends State<ItemListScreen> {
//   late Future<void> _fetchItemsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchItemsFuture = _fetchItems();
//   }

//   Future<void> _fetchItems() async {
//     final rssProvider = Provider.of<RssProvider>(context, listen: false);
//     await rssProvider.fetchItems(widget.feedUrl);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context);

//     return FutureBuilder<void>(
//       future: _fetchItemsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error loading items: ${snapshot.error}'),
//           );
//         } else {
//           final items = rssProvider.items;

//           if (items.isEmpty) {
//             return const Center(
//               child: Text('No items found for this feed.'),
//             );
//           }

//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return ListTile(
//                 title: Text(item['title'] ?? 'No title'),
//                 subtitle: Text(item['time'] ?? 'No time'),
//                 onTap: () {
//                   final url = item['link'];
//                   if (url != null) {
//                     // 导航到 ContentsScreen 并传递链接
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => HomeScaffold(
//                           body: ContentsScreen(
//                           url: url,
//                           title: item['title'] ?? 'No title',
//                           ),
//                           selectedIndex: 1, // Ensure this matches the index for RssScreen
//                           showLabels: true, // Adjust based on your needs
//                           bookScreenKey: GlobalKey<BookScreenState>(),
//                           rssScreenKey: GlobalKey<RssScreenState>(),
//                           toggleLabels: (value) {
//                             // Handle label toggling if needed
//                           },
//                           appBarTitle: item['title'] ?? 'No title',
//                         ),
//                         )
//                     );
//                   }
//                 },
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }





//1

// import 'package:flutter/material.dart';

// class ItemListScreen extends StatelessWidget {
//   final String feedUrl;

//   const ItemListScreen({super.key, required this.feedUrl});

//   @override
//   Widget build(BuildContext context) {
//     // 根据 feedUrl 获取该 Feed 的 item 列表

//     // 暂时用一个占位符表示
//     return Center(
//         child: Text('显示 $feedUrl 的项目列表'),
//     );
//   }
// }
