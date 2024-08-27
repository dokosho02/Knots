// import 'package:flutter/material.dart';
// import 'package:frb_code/ui/home_scaffold.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// // import 'package:frb_code/ui/editor_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   final GlobalKey<BookScreenState> _bookScreenKey = GlobalKey<BookScreenState>();
//   final GlobalKey<RssScreenState> _rssScreenKey = GlobalKey<RssScreenState>();
//   bool _showLabels = true; // 控制标签显示

//   @override
//   Widget build(BuildContext context) {
//     return HomeScaffold(
//       showLabels: _showLabels,
//       bookScreenKey: _bookScreenKey,
//       rssScreenKey: _rssScreenKey,
//       toggleLabels: (value) {
//         setState(() {
//           _showLabels = value;
//         });
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:frb_code/ui/home_scaffold.dart';

// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/editor_screen.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   final int _selectedIndex = 1;
//   final GlobalKey<BookScreenState> _bookScreenKey = GlobalKey<BookScreenState>();
//   final GlobalKey<RssScreenState> _rssScreenKey = GlobalKey<RssScreenState>();
//   final GlobalKey<EditorScreenState> _editorScreenKey = GlobalKey<EditorScreenState>();
//   // late List<ContentsScreen> _screens;
//   late List<Widget> _screens;
//   bool _showLabels = true; // 控制标签显示

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       BookScreen(key: _bookScreenKey),
//       RssScreen(
//         key: _rssScreenKey,
//         // rssScreenKey: _rssScreenKey,
//         // bookScreenKey: _bookScreenKey,
//         // showLabels: _showLabels,
//         // toggleLabels: (value) {
//         //   setState(() {
//         //     _showLabels = value;
//         //   });
//         // },
//       ),
//       EditorScreen(key: _editorScreenKey),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return HomeScaffold(
//       body: _screens[_selectedIndex],
//       selectedIndex: _selectedIndex,
//       showLabels: _showLabels,
//       bookScreenKey: _bookScreenKey,
//       rssScreenKey: _rssScreenKey,
//       editorScreenKey: _editorScreenKey,
//       toggleLabels: (value) {
//         setState(() {
//           _showLabels = value;
//         });
//       },
//     );
//   }
// }
