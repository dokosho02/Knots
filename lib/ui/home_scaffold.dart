import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:frb_code/ui/editor_screen.dart';
// import 'package:frb_code/ui/utils/settings_screen.dart';
// import 'package:frb_code/ui/utils/add_feed_screen.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  HomeScaffoldState createState() => HomeScaffoldState();
}

class HomeScaffoldState extends State<HomeScaffold> {
  final Logger _logger = Logger();
  int _currentIndex = 1; // Default to RSS screen

  void _onBottomItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        switch (index) {
          case 0:
            context.go('/book');
            break;
          case 1:
            context.go('/rss');
            break;
          case 2:
            context.go('/editor');
            break;
        }
      });
    }
  }

  void _onPlusButtonPressed() {
    if (_currentIndex == 0) {
      _logger.i("Add new book");
      context.go('/book'); // Add logic to handle adding books
    } else if (_currentIndex == 1) {
      _logger.i("Add new RSS feed");
      context.go('/add-feed');
    } else if (_currentIndex == 2) {
      _logger.i("Create new document");
      // Implement new document creation logic here
    }
  }

  void _openSettings() {
    context.go('/settings');
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Book Reader';
      case 1:
        return 'RSS Feed';
      case 2:
        return 'Text Editor';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add/New/Open',
            onPressed: _onPlusButtonPressed,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          BookScreen(),
          RssScreen(),
          EditorScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'RSS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Editor',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onBottomItemTapped,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/editor_screen.dart';
// import 'package:frb_code/ui/utils/settings_screen.dart';
// import 'package:frb_code/ui/utils/add_feed_screen.dart';

// class HomeScaffold extends StatefulWidget {
//   final Widget body;
//   final int selectedIndex;
//   final bool showLabels;
//   final GlobalKey<BookScreenState> bookScreenKey;
//   final GlobalKey<RssScreenState> rssScreenKey;
//   final GlobalKey<EditorScreenState> editorScreenKey;
//   final ValueChanged<bool> toggleLabels;
//   final String? appBarTitle;

//   const HomeScaffold({
//     super.key,
//     required this.showLabels,
//     required this.bookScreenKey,
//     required this.rssScreenKey,
//     required this.editorScreenKey,
//     required this.toggleLabels,
//     required  this.body,
//     required this.selectedIndex,
//     this.appBarTitle,
//   });

//   @override
//   HomeScaffoldState createState() => HomeScaffoldState();
// }

// class HomeScaffoldState extends State<HomeScaffold> {
//   final Logger _logger = Logger();
//   int _currentIndex = 1;  // Default to RSS screen

//   final List<GlobalKey<NavigatorState>> _navigatorKeys = [
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//   ];

//   void _onBottomItemTapped(int index) {
//     if (index != _currentIndex) {
//       setState(() {
//         _currentIndex = index;
//       });
//     }
//   }

//   void _onPlusButtonPressed() {
//     if (_currentIndex == 0) {
//       _logger.i("Add new book");
//       widget.bookScreenKey.currentState?.pickAndProcessFile();
//     } else if (_currentIndex == 1) {
//       _logger.i("Add new RSS feed");
//       _openAddFeed();
//     } else if (_currentIndex == 2) {
//       _logger.i("Create new document");
//       // Implement new document creation logic here
//     }
//   }

//   void _openAddFeed() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddFeedScreen(),
//       ),
//     );
//   }

//   void _openSettings() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SettingsScreen(
//           showLabels: widget.showLabels,
//           onToggleLabels: widget.toggleLabels,
//         ),
//       ),
//     );
//   }

//   String _getAppBarTitle() {
//     switch (_currentIndex) {
//       case 0:
//         return 'Book Reader';
//       case 1:
//         return 'RSS Feed';
//       case 2:
//         return 'Text Editor';
//       default:
//         return 'Home';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) async {
//         if (didPop) return;

//         final NavigatorState navigator = _navigatorKeys[_currentIndex].currentState!;
//         if (!navigator.canPop()) {
//           if (_currentIndex != 1) {
//             setState(() {
//               _currentIndex = 1;
//             });
//           } else {
//             // 如果已经在主标签页（RSS），则退出应用
//             // 注意：在实际应用中，你可能想要显示一个确认对话框
//             Navigator.of(context).pop();
//           }
//         } else {
//           navigator.pop();
//         }
//       },
//       child:
//       Scaffold(
//         appBar: AppBar(
//           title: Text(_getAppBarTitle()),
//           actions: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.add),
//               tooltip: 'Add/New/Open',
//               onPressed: _onPlusButtonPressed,
//             ),
//             IconButton(
//               icon: const Icon(Icons.settings),
//               tooltip: 'Settings',
//               onPressed: _openSettings,
//             ),
//           ],
//         ),
//         // body: IndexedStack(
//         //   index: _currentIndex,
//         //   children: [
//         //     _buildNavigator(0, widget.bookScreenKey),
//         //     _buildNavigator(1, widget.rssScreenKey),
//         //     _buildNavigator(2, null),
//         //   ],
//         // ),
//         body: _currentIndex == widget.selectedIndex
//             ? widget.body
//             : IndexedStack(
//                 index: _currentIndex,
//                 children: [
//                   _buildNavigator(0, widget.bookScreenKey),
//                   _buildNavigator(1, widget.rssScreenKey),
//                   _buildNavigator(2, widget.editorScreenKey),
//                 ],
//               ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.book),
//               label: 'Book',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.rss_feed),
//               label: 'RSS',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.edit),
//               label: 'Editor',
//             ),
//           ],
//           currentIndex: _currentIndex,
//           selectedItemColor: Colors.amber[800],
//           onTap: _onBottomItemTapped,
//           showSelectedLabels: widget.showLabels,
//           showUnselectedLabels: widget.showLabels,
//         ),
//       ),
//     );
//   }

//   Widget _buildNavigator(int index, Key? screenKey) {
//     return Navigator(
//       key: _navigatorKeys[index],
//       onGenerateRoute: (RouteSettings settings) {
//         return MaterialPageRoute(
//           builder: (BuildContext context) {
//             switch (index) {
//               case 0:
//                 return BookScreen(
//                   key: screenKey as GlobalKey<BookScreenState>,
//                 );
//               case 1:
//                 return const RssScreen(
//                   // showLabels: widget.showLabels,
//                   // toggleLabels: widget.toggleLabels,
//               );
//               case 2:
//                 return const EditorScreen();
//               default:
//                 return const SizedBox.shrink();
//             }
//           },
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/editor_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:logger/logger.dart';
// import 'package:frb_code/ui/utils/settings_screen.dart';
// import 'package:frb_code/ui/utils/add_feed_screen.dart';

// class HomeScaffold extends StatefulWidget {
//   final Widget body;
//   final int selectedIndex;
//   final bool showLabels;
//   final GlobalKey<BookScreenState> bookScreenKey;
//   final GlobalKey<RssScreenState> rssScreenKey;
//   final ValueChanged<bool> toggleLabels;
//   final String? appBarTitle;

//   const HomeScaffold({
//     super.key,
//     required this.body,
//     required this.selectedIndex,
//     required this.showLabels,
//     required this.toggleLabels,
//     required this.bookScreenKey,
//     required this.rssScreenKey,
//     this.appBarTitle,
//   });

//   @override
//   HomeScaffoldState createState() => HomeScaffoldState();
// }

// class HomeScaffoldState extends State<HomeScaffold> {
//   final Logger _logger = Logger();
  

//   void _onBottomItemTapped(int index) {
//     if (index != widget.selectedIndex) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScaffold(
//             body: _getBodyForIndex(index),
//             selectedIndex: index,
//             showLabels: widget.showLabels,
//             bookScreenKey: widget.bookScreenKey,
//             rssScreenKey: widget.rssScreenKey,
//             toggleLabels: widget.toggleLabels,
//             appBarTitle: widget.appBarTitle,
//           ),
//         ),
//         // (route) => route.isFirst,
//       );
//     }
//   }

//   Widget _getBodyForIndex(int index) {
//     switch (index) {
//       case 0:
//         return BookScreen(key: widget.bookScreenKey);
//       case 1:
//         return RssScreen(key: widget.rssScreenKey);
//       case 2:
//         return const EditorScreen();
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   void _onPlusButtonPressed() {
//     if (widget.selectedIndex == 0) {
//       _logger.i("Add new book");
//       widget.bookScreenKey.currentState?.pickAndProcessFile();
//     } else if (widget.selectedIndex == 1) {
//       _logger.i("Add new RSS feed");
//       _openAddFeed();
//     } else if (widget.selectedIndex == 2) {
//       _logger.i("Create new document");
//     }
//   }

//   void _openAddFeed() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddFeedScreen(),
//       ),
//     );
//   }

//   void _openSettings() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SettingsScreen(
//           showLabels: widget.showLabels,
//           onToggleLabels: widget.toggleLabels,
//         ),
//       ),
//     );
//   }


//   String _getDefaultAppBarTitle() {
//     switch (widget.selectedIndex) {
//       case 0:
//         return 'Book Reader';
//       case 1:
//         return 'RSS Feed';
//       case 2:
//         return 'Text Editor';
//       default:
//         return 'Home';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.appBarTitle ?? _getDefaultAppBarTitle(),
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'Add/New/Open',
//             onPressed: _onPlusButtonPressed,
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             tooltip: 'Settings',
//             onPressed: _openSettings,
//           ),
//         ],
//       ),
//       body: widget.body,
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.book),
//             label: 'Book',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.rss_feed),
//             label: 'RSS',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.edit),
//             label: 'Editor',
//           ),
//         ],
//         currentIndex: widget.selectedIndex,
//         selectedItemColor: Colors.amber[800],
//         onTap: _onBottomItemTapped,
//         showSelectedLabels: widget.showLabels,
//         showUnselectedLabels: widget.showLabels,
//       ),
//     );
//   }

  

// }
