// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/lists/scroll_area.dart';

import 'package:flutter/material.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/home_scaffold.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/item_list_screen.dart';
import 'package:frb_code/ui/lists/scroll_area.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context);
    final scrollController = ScrollController();
    const paddingValue = 16.0;

    return Scaffold(
      body: Stack(
        children: [
          // Padding(
            // padding: EdgeInsets.symmetric(horizontal: 16.0), // 设置左右 padding
            // child: 
            ListView(
              controller: scrollController,
              children: rssProvider.feeds.map((feed) {
                final feedLink = feed['link']!;
                final feedTitle = feed['title']!;
                return ListTile(
                  title: Text(feedTitle),
                  onTap: () {
                    // Navigate to ItemListScreen with HomeScaffold
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScaffold(
                          body: ItemListScreen(feedUrl: feedLink),
                          selectedIndex: 1, // Ensure this matches the index for RssScreen
                          showLabels: true, // Adjust based on your needs
                          bookScreenKey: GlobalKey<BookScreenState>(),
                          rssScreenKey: GlobalKey<RssScreenState>(),
                          toggleLabels: (value) {
                            // Handle label toggling if needed
                          },
                          appBarTitle: feedTitle,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          // ),
          ScrollArea(
            scrollController: scrollController,
            contentPadding: paddingValue, // 设置适当的 padding
          ),
        ],
      ),
    );
  }
}



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
