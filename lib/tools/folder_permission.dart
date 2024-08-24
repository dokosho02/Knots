import 'dart:io';
import 'package:permission_handler/permission_handler.dart';



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
  } else {
    return "/storage/emulated/0/Download/sync";
  }
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

