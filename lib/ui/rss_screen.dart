import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/group_list_screen.dart';

class RssScreen extends StatefulWidget {
  const RssScreen({super.key});

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
    // 调用异步函数
    Provider.of<RssProvider>(context, listen: false).fetchFeeds();
  }
  void addFeed(String url) {
    Provider.of<RssProvider>(context, listen: false).addFeed(url);
  }


  @override
  Widget build(BuildContext context) {
    return const GroupListScreen();
  }
}
