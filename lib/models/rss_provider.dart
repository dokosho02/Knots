
//3
import 'package:flutter/material.dart';
import 'package:frb_code/src/rust/api/simple.dart';
import 'package:logger/logger.dart';

import 'package:frb_code/tools/folder_permission.dart';


class RssProvider with ChangeNotifier {
  final Logger _logger = Logger();
  
  // 将 _feeds 从 List<String> 改为 List<Map<String, String>>，以存储标题和链接
  List<Map<String, String>> _feeds = [];
  List<Map<String, String>> get feeds => _feeds;
// 存储 items，结构为：List<Map<String, String>>
  List<Map<String, String>> _items = [];
  List<Map<String, String>> get items => _items;

  Future<void> addFeed(String url) async {
    _feeds.add({'title': '', 'link': url});  // 示例添加 feed，链接可以根据实际情况设置

    final fullPath = await getFullDatabaseName();
    await addFeedToDatabaseAsync(dbPath: fullPath, title: "", link: url);

    notifyListeners();
  }


  Future<void> fetchFeeds() async {
    // init current settings db
    final databaseName = await getCurrentSettingsDatabaseName();
    await createCurrentSettingsDbAsync(dbPath: databaseName);

    print("databaseName: $databaseName in fetchFeeds");

    final fullPath = await getFullDatabaseName();
    try {
      // 保留从数据库获取的标题和链接
      final List<(String, String)> feedsResult = await fetchFeedsFromDatabaseAsync(dbPath: fullPath);

      // 使用 Map 存储标题和链接
      _feeds = feedsResult.map((e) => {'title': e.$1, 'link': e.$2}).toList();

      notifyListeners();
    } catch (e) {
      _logger.e("Failed to fetch feeds: $e");
    }
  }

  Future<void> fetchItems(String feedLink) async {

    // get current rss db
    final fullPath = await getFullDatabaseName();
    print("fullPath: $fullPath in fetchItems");
    if (_feeds.isEmpty) {
      _logger.e("No feeds to fetch items from for feed $feedLink");
      return;
    }

    try {
      // 调用 Rust 异步函数
      final List<(String, String, String)> itemsResult = await fetchItemsByFeedLinkAsync(dbPath: fullPath, feedLink: feedLink);
      // final List<(String, String, String)> itemsResult = await fetchItemsMetaByFeedLinkAsync(dbPath: fullPath, feedLink: feedLink);

      // 使用 Map 存储 item 的数据
      _items = itemsResult.map((e) => {
        'title': e.$1,  // Item 的标题
        'link': e.$2,  // Item 的描述
        'time': e.$3,   // Item 的链接
        // 'isStarred': e.$4.toString(),  // Item 是否被标记为 Starred
        // 'isRead': e.$5.toString()  // Item 是否被标记为 Read
      }).toList();

      notifyListeners();
    } catch (e) {
      _logger.e("Failed to fetch items for feed $feedLink: $e");
    }
  }

  Future<String> fetchContents(String itemLink) async {
    final fullPath = await getFullDatabaseName();
    try {
      // 调用 Rust 异步函数
      final String contents = await fetchContentsByItemLinkAsync(dbPath: fullPath, itemLink: itemLink);
      // 处理内容
      _logger.i("Contents from item $itemLink fetched:\n$contents");
      return contents;
    } catch (e) {
      _logger.e("Failed to fetch contents for item $itemLink: $e");
      return "Failed to fetch contents";
    }
  }


}



//1
// import 'package:flutter/material.dart';
// // import 'package:frb_code/src/rust/api/simple.dart';

// class RssProvider with ChangeNotifier {
//   List<String> _feeds = [];
//   List<String> get feeds => _feeds;

//   void addFeed(String url) {
//     _feeds.add(url);
//     notifyListeners();
//   }
// }




//2



// import 'package:flutter/material.dart';
// import 'package:frb_code/src/rust/api/simple.dart';
// import 'package:logger/logger.dart';
// import 'dart:io';

// import 'package:path/path.dart';
// import 'package:frb_code/tools/utils.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class RssProvider with ChangeNotifier {
//   final Logger _logger = Logger();
//   // List<(String, String)> _feeds = [];
//   // List<(String, String)> get feeds => _feeds;
//   List<String> _feeds = [];
//   List<String> get feeds => _feeds;
  
//   Future<void> fetchFeeds() async {
//     const databaseName = "rss.db";
//     String? dbFolder;

//     if (isDesktop) {
//     // get env sync
//       dbFolder = Platform.environment['sync'];
//     } else {
//       dbFolder = "/storage/emulated/0/Download/sync";
//       // Directory? externalDir = await getExternalStorageDirectory();
//       // _logger.i("externalDir: $externalDir");
//     }
//     final fullPath = join(dbFolder!, databaseName);
//     _logger.i("fullPath: $fullPath");

//     final fileExists = await checkIfFileExists(filePath: fullPath);
//     _logger.i("fileExists: $fileExists");

//     // // write a test text file to the folder
//     // final testFilePath = join(dbFolder, "test.txt");
//     // _logger.i("testFilePath: $testFilePath");
//     // await writeTextToFile(filePath: testFilePath, text: "Hello, world!");

//     // // read the test text file
//     // final testFile = File(testFilePath);
    
//     // final testFileContent = await testFile.readAsString();
//     // _logger.i("testFileContent: $testFileContent");
    

//     await requestManageExternalStoragePermission();
//     bool hasPermission = await Permission.manageExternalStorage.isGranted;

//     if (!hasPermission) {
//       await openAppSettings();
//     } else {
//       _logger.i("Permission granted");
//     }

//     // create a database
//     // Directory appDocDir = await getApplicationDocumentsDirectory();
//     // final newPath = join(appDocDir.path, "rss.db");
//     // _logger.i("newPath: $newPath");
//     // final newPath = join(dbFolder, "test.db");
//     // await createDb(newPath);



//     // copy file of full path to appDocDir
//     // final newDbPath = join(appDocDir.path, databaseName);
//     // _logger.i("newDbPath: $newDbPath");
//     // final isAppDirDbExists = await checkIfFileExists(filePath: newDbPath);
//     // _logger.i("isAppDirDbExists: $isAppDirDbExists");
//     // if (!isAppDirDbExists) {
//     //   final file = File(fullPath);
//     //   await file.copy(newDbPath);
//     // }

//     try {
//       // 调用 Rust 异步函数
//       final List<(String, String)> feedsResult = await fetchFeedsFromDatabaseAsync(dbPath: fullPath);
//       // final List<(String, String)> feedsResult = (await fetchFeedsFromDb(newDbPath)).cast<(String, String)>();

//       // 更新本地状态
//       // _feeds = fetchedFeeds;
//       _feeds = feedsResult.map((e) => e.$1).toList();
//       // 通知监听者
//       notifyListeners();
//     } catch (e) {
//       _logger.e("Failed to fetch feeds: $e");
//       // 错误处理
//     }
//   }
  
//   Future<void> writeTextToFile({required String filePath, required String text}) async {
//     final file = File(filePath);
//     await file.writeAsString(text);
//   }

//   void addFeed(String url) {
//     // _feeds.add((url, "")); // 示例添加 feed，需要根据实际情况调整
//     _feeds.add(url);
//     notifyListeners();
//   }
// }
