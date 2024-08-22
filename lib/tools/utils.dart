import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

Future<void> requestStoragePermission() async {
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



// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';

// final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

// Future<void> requestManageExternalStoragePermission() async {
//   var status = await Permission.manageExternalStorage.status;
//   if (!status.isGranted) {
//     await Permission.manageExternalStorage.request();
//   }
// }

