import 'package:flutter/material.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/editor_screen.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:logger/logger.dart';
import 'package:frb_code/ui/utils/settings_screen.dart';
import 'package:frb_code/ui/utils/add_feed_screen.dart';

class HomeScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final bool showLabels;
  final GlobalKey<BookScreenState> bookScreenKey;
  final GlobalKey<RssScreenState> rssScreenKey;
  final ValueChanged<bool> toggleLabels;
  final String? appBarTitle;

  const HomeScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.showLabels,
    required this.toggleLabels,
    required this.bookScreenKey,
    required this.rssScreenKey,
    this.appBarTitle,
  });

  @override
  HomeScaffoldState createState() => HomeScaffoldState();
}

class HomeScaffoldState extends State<HomeScaffold> {
  final Logger _logger = Logger();
  

  void _onBottomItemTapped(int index) {
    if (index != widget.selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScaffold(
            body: _getBodyForIndex(index),
            selectedIndex: index,
            showLabels: widget.showLabels,
            bookScreenKey: widget.bookScreenKey,
            rssScreenKey: widget.rssScreenKey,
            toggleLabels: widget.toggleLabels,
            appBarTitle: widget.appBarTitle,
          ),
        ),
        // (route) => route.isFirst,
      );
    }
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return BookScreen(key: widget.bookScreenKey);
      case 1:
        return RssScreen(key: widget.rssScreenKey);
      case 2:
        return const EditorScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _onPlusButtonPressed() {
    if (widget.selectedIndex == 0) {
      _logger.i("Add new book");
      widget.bookScreenKey.currentState?.pickAndProcessFile();
    } else if (widget.selectedIndex == 1) {
      _logger.i("Add new RSS feed");
      _openAddFeed();
    } else if (widget.selectedIndex == 2) {
      _logger.i("Create new document");
    }
  }

  void _openAddFeed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFeedScreen(),
      ),
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          showLabels: widget.showLabels,
          onToggleLabels: widget.toggleLabels,
        ),
      ),
    );
  }


  String _getDefaultAppBarTitle() {
    switch (widget.selectedIndex) {
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
        title: Text(
          widget.appBarTitle ?? _getDefaultAppBarTitle(),
        ),
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
      body: widget.body,
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
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onBottomItemTapped,
        showSelectedLabels: widget.showLabels,
        showUnselectedLabels: widget.showLabels,
      ),
    );
  }

}
