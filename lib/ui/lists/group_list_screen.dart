// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/lists/scroll_area.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/editor_screen.dart';


import 'package:frb_code/src/rust/api/simple.dart';
import 'package:frb_code/tools/folder_permission.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/utils/scroll_area.dart';


class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  GroupListScreenState createState() => GroupListScreenState();
}

class GroupListScreenState extends State<GroupListScreen> {
  Future<void> updateCurrentFeedLink(String feedLink) async {
    final databaseName = await getCurrentSettingsDatabaseName();
    await updateCurrentFeedLinkAsync(dbPath: databaseName, link: feedLink);
  }

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context);
    final scrollController = ScrollController();
    final screenWidth = MediaQuery.of(context).size.width;

    double paddingValue = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS Feed'),
      ),
      body: Stack(
        children: [
          ListView(
            controller: scrollController,
            children: rssProvider.feeds.map((feed) {
              final feedLink = feed['link']!;
              final feedTitle = feed['title']!;
              return ListTile(
                title: Text(feedTitle),
                onTap: () async {
                  await updateCurrentFeedLink(feedLink);

                  if (!mounted) return;

                  // 在异步操作后再获取 BuildContext
                  final currentContext = context;
                  if (currentContext.mounted) {
                    GoRouter.of(currentContext).go('/b/b2/');
                  }
                },
              );
            }).toList(),
          ),
          ScrollArea(
            scrollController: scrollController,
            contentPadding: paddingValue,
          ),
        ],
      ),
    );
  }
}



// class GroupListScreen extends StatelessWidget {
//   // final GlobalKey<BookScreenState> bookScreenKey;
//   // final GlobalKey<RssScreenState> rssScreenKey;
//   // final bool showLabels;
//   // final ValueChanged<bool> toggleLabels;

//   const GroupListScreen({
//     super.key,
//     // required this.bookScreenKey,
//     // required this.rssScreenKey,
//     // required this.showLabels,
//     // required this.toggleLabels,
//   });

//   Future<void> updateCurrentFeedLink(String feedLink) async {
//     final databaseName = await getCurrentSettingsDatabaseName();
//     await updateCurrentFeedLinkAsync(dbPath: databaseName, link: feedLink);
//     // print('current Feed link updated to $feedLink');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context);
//     final scrollController = ScrollController();
//     final screenWidth = MediaQuery.of(context).size.width;

//     double paddingValue = screenWidth * 0.05;
//   // bool _showLabels = true; // 控制标签显示

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('RSS Feed'),
//       ),
//       body: Stack(
//         children: [
//           ListView(
//             controller: scrollController,
//             children: rssProvider.feeds.map((feed) {
//               final feedLink = feed['link']!;
//               final feedTitle = feed['title']!;
//               return ListTile(
//                 title: Text(feedTitle),
//                 onTap: () {
//                   updateCurrentFeedLink(feedLink);
//                   GoRouter.of(context).go('/b/b2/');
//                 },
//               );
//             }).toList(),
//           ),
//           ScrollArea( 
//             scrollController: scrollController,
//             contentPadding: paddingValue,
//           ),
//         ],
//       ),
//     );
//   }
// }




// 2


// import 'package:flutter/material.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/lists/utils/scroll_area.dart';


// class GroupListScreen extends StatelessWidget {
//   const GroupListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context);
//     final scrollController = ScrollController();
//     const paddingValue = 16.0;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Padding(
//             // padding: EdgeInsets.symmetric(horizontal: 16.0), // 设置左右 padding
//             // child: 
//             ListView(
//               controller: scrollController,
//               children: rssProvider.feeds.map((feed) {
//                 final feedLink = feed['link']!;
//                 final feedTitle = feed['title']!;
//                 return ListTile(
//                   title: Text(feedTitle),
//                   onTap: () {
//                     // Navigate to ItemListScreen with HomeScaffold
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => HomeScaffold(
//                           body: ItemListScreen(feedUrl: feedLink),
//                           selectedIndex: 1, // Ensure this matches the index for RssScreen
//                           showLabels: true, // Adjust based on your needs
//                           bookScreenKey: GlobalKey<BookScreenState>(),
//                           rssScreenKey: GlobalKey<RssScreenState>(),
//                           toggleLabels: (value) {
//                             // Handle label toggling if needed
//                           },
//                           appBarTitle: feedTitle,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }).toList(),
//             ),
//           // ),
//           ScrollArea(
//             scrollController: scrollController,
//             contentPadding: paddingValue, // 设置适当的 padding
//           ),
//         ],
//       ),
//     );
//   }
// }



// 1

// import 'package:flutter/material.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';

// class GroupListScreen extends StatelessWidget {
//   const GroupListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final rssProvider = Provider.of<RssProvider>(context);

//     return ListView(
//       children: rssProvider.feeds.map((feed) {
//         final feedLink = feed['link']!;
//         final feedTitle = feed['title']!;
//         return ListTile(
//           title: Text(feedTitle),
//           onTap: () {
//             // Navigate to ItemListScreen with HomeScaffold
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomeScaffold(
//                   body: ItemListScreen(feedUrl: feedLink),
//                   selectedIndex: 1, // Ensure this matches the index for RssScreen
//                   showLabels: true, // Adjust based on your needs
//                   bookScreenKey: GlobalKey<BookScreenState>(),
//                   rssScreenKey: GlobalKey<RssScreenState>(),
//                   toggleLabels: (value) {
//                     // Handle label toggling if needed
//                   },
//                   appBarTitle: feedTitle,
//                 ),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
// }
