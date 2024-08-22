// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// // import 'package:frb_code/ui/editor_screen.dart';
// import 'package:frb_code/ui/lists/group_list_screen.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/utils/add_feed_screen.dart';
// import 'package:frb_code/ui/utils/settings_screen.dart';

// final GoRouter router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => HomeScaffold(
//         body: const RssScreen(),
//         selectedIndex: 1,
//         showLabels: true,
//         bookScreenKey: GlobalKey<BookScreenState>(),
//         rssScreenKey: GlobalKey<RssScreenState>(),
//         toggleLabels: (value) {},
//       ),
//       routes: [
//         GoRoute(
//           path: 'group_list',
//           builder: (context, state) => const GroupListScreen(),
//           routes: [
//             GoRoute(
//               path: 'item_list/:feedUrl',
//               builder: (context, state) {
//                 final feedUrl = state.pathParameters['feedUrl']!;
//                 return HomeScaffold(
//                   body: ItemListScreen(feedUrl: feedUrl),
//                   selectedIndex: 1,
//                   showLabels: true,
//                   bookScreenKey: GlobalKey<BookScreenState>(),
//                   rssScreenKey: GlobalKey<RssScreenState>(),
//                   toggleLabels: (value) {},
//                   appBarTitle: feedUrl,
//                 );
//               },
//             ),
//           ],
//         ),
//         GoRoute(
//           path: 'add_feed',
//           builder: (context, state) => const AddFeedScreen(),
//         ),
//         GoRoute(
//           path: 'settings',
//           builder: (context, state) => SettingsScreen(
//             showLabels: true,
//             onToggleLabels: (value) {},
//           ),
//         ),
//       ],
//     ),
//   ],
// );
