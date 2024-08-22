
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/home_scaffold.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:frb_code/ui/lists/contents_screen.dart';
import 'package:frb_code/ui/lists/scroll_area.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/contents_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/scroll_area.dart'; // 导入 ScrollArea

class ItemListScreen extends StatefulWidget {
  final String feedUrl;

  const ItemListScreen({super.key, required this.feedUrl});

  @override
  ItemListScreenState createState() => ItemListScreenState();
}

class ItemListScreenState extends State<ItemListScreen> {
  late Future<void> _fetchItemsFuture;
  late ScrollController _scrollController;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context);
    const paddingValue = 16.0;
    return Scaffold(
      body: Stack(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: paddingValue), // 设置左右 padding
          // child: 
          FutureBuilder<void>(
            future: _fetchItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading items: ${snapshot.error}'),
                );
              } else {
                final items = rssProvider.items;

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items found for this feed.'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController, // 使用 ScrollController
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['title'] ?? 'No title'),
                      subtitle: Text(item['time'] ?? 'No time'),
                      onTap: () {
                        final url = item['link'];
                        if (url != null) {
                          // 导航到 ContentsScreen 并传递链接
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScaffold(
                                body: ContentsScreen(
                                  url: url,
                                  title: item['title'] ?? 'No title',
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
                      },
                    );
                  },
                );
              }
            },
          ),
          // ),
          ScrollArea(
            scrollController: _scrollController,
            contentPadding: paddingValue, // 设置适当的 padding
          ),
        ],
      ),
    );
  }
}



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
