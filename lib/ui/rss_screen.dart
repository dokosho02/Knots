import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/group_list_screen.dart';
// import 'package:frb_code/ui/book_screen.dart';

// import 'package:frb_code/src/rust/api/simple.dart';
// import 'package:frb_code/tools/folder_permission.dart';
class RssScreen extends StatefulWidget {
  // final GlobalKey<RssScreenState> rssScreenKey;
  // final GlobalKey<BookScreenState> bookScreenKey;
  // final bool showLabels;
  // final ValueChanged<bool> toggleLabels;

  const RssScreen({
    super.key,
    // required this.rssScreenKey,
    // required this.bookScreenKey,
    // required this.showLabels,
    // required this.toggleLabels,
  });

  @override
  RssScreenState createState() => RssScreenState();
}

class RssScreenState extends State<RssScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFeedsOnInit();
  }

  void _fetchFeedsOnInit() {
    Provider.of<RssProvider>(context, listen: false).fetchFeeds();
  }


  void addFeed(String url) {
    Provider.of<RssProvider>(context, listen: false).addFeed(url);
  }

  @override
  Widget build(BuildContext context) {
    return const GroupListScreen(
      // bookScreenKey: widget.bookScreenKey,
      // rssScreenKey: widget.rssScreenKey,
      // showLabels: widget.showLabels,
      // toggleLabels: widget.toggleLabels,
    );
    // return const Text('RssScreen');
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/lists/group_list_screen.dart';

// class RssScreen extends StatefulWidget {
//   const RssScreen({super.key});

//   @override
//   RssScreenState createState() => RssScreenState();
// }

// class RssScreenState extends State<RssScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _fetchFeedsOnInit();
//   }

//   void _fetchFeedsOnInit() {
//     // 调用异步函数
//     Provider.of<RssProvider>(context, listen: false).fetchFeeds();
//   }
//   void addFeed(String url) {
//     Provider.of<RssProvider>(context, listen: false).addFeed(url);
//   }


//   @override
//   Widget build(BuildContext context) {
//     return const GroupListScreen();
//   }
// }
