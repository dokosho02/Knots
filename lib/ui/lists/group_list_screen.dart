import 'package:frb_code/src/rust/api/simple.dart';
import 'package:frb_code/tools/folder_permission.dart';

import 'package:flutter/material.dart';
import 'package:frb_code/tools/fonts_tools.dart';
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
    
    double fontSize = calculateFontSize(context);

    return Scaffold(
      appBar: AppBar(
        title: buildRichTextWithMaxLines(
          text: "RSS Feeds", 
          fontSize: fontSize,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            controller: scrollController,
            children: rssProvider.feeds.map((feed) {
              final feedLink = feed['link']!;
              final feedTitle = feed['title']!;
              // final isStarred = feed['isStarred'];
              // final isRead = feed['isRead'];
              
              // print('feedTitle: $feedTitle, isStarred: $isStarred, isRead: $isRead');

              return ListTile(
                // title: Text(
                //   feedTitle,
                //   style: TextStyle(
                //     // color: isRead == '1' ? Colors.grey : Colors.black,
                //     // fontWeight: isStarred == '1' ? FontWeight.bold : FontWeight.normal,
                //     fontSize: fontSize,
                //   ),
                // ),
                  title: buildRichTextWithMaxLines(
                    text: feedTitle,
                    fontSize: fontSize,
                    maxLines: 2, // 设置最大行数为 2
                  ),
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

