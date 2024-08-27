import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:frb_code/src/rust/api/simple.dart';

import 'package:path/path.dart';

const databaseName = "rss.db";
const currentSettingsDatabaseName = "current_log.db";

final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

Future<void> checkStoragePermission() async {
  if (Platform.isAndroid && Platform.version.startsWith('8')) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  } else {
    // 在 Android 11+ 的设备上请求 manageExternalStorage
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }
}

Future<void> requestStoragePermission() async {

  await checkStoragePermission();
  bool hasPermission = false;
  if (Platform.isAndroid && Platform.version.startsWith('8')) {
    hasPermission = await Permission.storage.isGranted;
  } else {
    hasPermission = await Permission.manageExternalStorage.isGranted;
  }


  if (!hasPermission) {
    openAppSettings();
  } else {
    print("Permission granted");
  }
}

Future<String> getFolder() async {
  if (isDesktop) {
    // get env sync
    return Platform.environment['sync']!;
  } else if (Platform.isAndroid) {
    return "/storage/emulated/0/Download/sync";
  } else {
    throw Exception("Unsupported platform, maybe iOS?");
  }
}

Future<String> getDocFolder() async {
  String userDir;
  const docDir = "Documents";

  if (isDesktop) {
    userDir = Platform.isWindows ? Platform.environment['USERPROFILE']! : Platform.environment['HOME']!;
  } else if (Platform.isAndroid) {
    userDir = "/storage/emulated/0";
  } else {
    throw Exception("Unsupported platform, maybe iOS?");
  }

  // Todo: iOS in the future
  return join(userDir, docDir);

}

Future<String> getCurrentSettingsDatabaseName() async {
  final dbFolder = await getDocFolder();
  final fullPath = join(dbFolder, currentSettingsDatabaseName);
  print("fullPath: $fullPath");

  final fileExists = await checkIfFileExists(filePath: fullPath);
  print("fileExists: $fileExists"); 

  return fullPath;
}

Future<String> getFullDatabaseName() async {
  final dbFolder = await getFolder();
  final fullPath = join(dbFolder, databaseName);
  print("fullPath: $fullPath");

  final fileExists = await checkIfFileExists(filePath: fullPath);
  print("fileExists: $fileExists");

  return fullPath;
}

// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';

// final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

// Future<void> requestManageExternalStoragePermission() async {
//   var status = await Permission.manageExternalStorage.status;
//   if (!status.isGranted) {
//     await Permission.manageExternalStorage.request();
//   }
// }

