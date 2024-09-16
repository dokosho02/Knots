import 'package:flutter/material.dart';
import 'package:frb_code/tools/fonts_tools.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/lists/utils/scroll_area.dart';
import 'package:frb_code/src/rust/api/simple.dart';
import 'package:frb_code/tools/folder_permission.dart';

class ItemListScreen extends StatefulWidget {
  // final String feedUrl;

  const ItemListScreen({super.key,
  // required this.feedUrl
  });

  @override
  ItemListScreenState createState() => ItemListScreenState();
}

class ItemListScreenState extends State<ItemListScreen> {
  late Future<void> _fetchItemsFuture;
  late ScrollController _scrollController;
  final Logger _logger = Logger();
  late String feedTitle;

  @override
  void initState() {
    super.initState();

    _fetchItemsFuture = _fetchItems();
    _scrollController = ScrollController();
  }

  Future<String> fetchCurrentFeedLink() async {
    final databaseName = await getCurrentSettingsDatabaseName();
    return await fetchCurrentFeedLinkAsync(dbPath: databaseName);
  }

  Future<String> fetchCurrentFeedTitle() async {
    final databaseName = await getFullDatabaseName();
    return await fetchFeedTitleAsync(dbPath: databaseName, link: await fetchCurrentFeedLink());
  }

  Future<void> updateCurrentItemLink(String itemLink) async {
    final databaseName = await getCurrentSettingsDatabaseName();
    await updateCurrentItemLinkAsync(dbPath: databaseName, link: itemLink);
  }

  Future<void> _fetchItems() async {
    final rssProvider = Provider.of<RssProvider>(context, listen: false);
    final currentFeedLink = await fetchCurrentFeedLink();
    feedTitle = await fetchCurrentFeedTitle();
    print('get current FeedLink: $currentFeedLink');
    await rssProvider.fetchItems(currentFeedLink);
  }

  Future<String> calculateRelativeTime(String utcTimeStr) async {
    try {
      final String relativeTime = await getRelativeTime(utcTimeStr: utcTimeStr);
      return relativeTime;
    } catch (e) {
      // _logger.e('Error calculating relative time', e);
      return "";
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildListTile(
    double screenWidth,
    double fontSize,
    String title,
    String? publishedAt,
    Widget? leadingWidget) {

    return ListTile(
      title: Row(
        children: [
          leadingWidget ?? const SizedBox.shrink(),
          if (publishedAt != null)
            SizedBox(
              width: screenWidth * 0.08,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  publishedAt,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          if (publishedAt != null)
            const SizedBox(width: 10.0),
          // Expanded(
          //   // child: Text(
          //   //   title,
          //   //   maxLines: 2,
          //   //   overflow: TextOverflow.ellipsis,
          //   //   style: TextStyle(
          //   //     // fontWeight: FontWeight.bold,
          //   //     fontSize: fontSize,
          //   //   ),
          //   // ),
          //   child: RichText(
          //     text: TextSpan(
          //       children: processText(
          //         title,
          //         TextStyle(
          //           fontSize: fontSize, // 设置统一的字体大小
          //         // color: textColor, // 使用动态颜色
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
            Expanded(
              child: buildRichTextWithMaxLines(
                text: title,
                fontSize: fontSize,
                maxLines: 2, // 设置最多显示 2 行
              ),
            ),

        ],
      ),
      onTap: () async{
        final rssProvider = Provider.of<RssProvider>(context, listen: false);
        final item = rssProvider.items.firstWhere((element) => element['title'] == title);
        final url = item['link'];
        if (url != null) {
          // final itemTitle = item['title'] ?? 'No title';
          // final itemPublishedAt = item['time'] ?? 'No time';

          // print('url: $url');
          // print('title: $itemTitle');
          // print('publishedAt: $itemPublishedAt');

          await updateCurrentItemLink(url);
          
          if (!mounted) return;

          // 在异步操作后再获取 BuildContext
          final currentContext = context;
          if (currentContext.mounted) {
          GoRouter.of(context).go('/b/b2/b3');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rssProvider = Provider.of<RssProvider>(context);
    // const paddingValue = 16.0;
    final screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;

    double fontSize = calculateFontSize(context);

    return FutureBuilder<void>(
      future: _fetchItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildListTile(
            screenWidth,
            fontSize,
            'Loading...',
            null,
            const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return _buildListTile(
            screenWidth,
            fontSize,
            'Error loading items: ${snapshot.error}',
            null,
            const Text('Error', style: TextStyle(color: Colors.red)),
          );
        } else {
          final items = rssProvider.items;

          if (items.isEmpty) {
            return const Center(
              child: Text('No items found for this feed'),
            );
          }

          // final 

          return Scaffold(
      appBar: AppBar(
        title: buildRichTextWithMaxLines(
                text: feedTitle,
                fontSize: fontSize,
                ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body:
          Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final title = item['title'] ?? 'No title';
                  final timeStr = item['time'] ?? 'No time';
                  _logger.i('timeStr: $timeStr');

                  return FutureBuilder<String>(
                    future: calculateRelativeTime(timeStr),
                    builder: (context, snapshot) {
                      final publishedAt = snapshot.data ?? '';
                      return _buildListTile(
                        screenWidth,
                        fontSize,
                        title,
                        publishedAt,
                        null,
                      );
                    },
                  );
                },
              ),
              ScrollArea(
                scrollController: _scrollController,
                contentPadding: paddingValue,
              ),
            ],
          ),
          );

        }
      },
    );
  }
}

