import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import 'package:frb_code/models/rss_provider.dart';
import 'package:frb_code/ui/book_screen.dart';
import 'package:frb_code/ui/rss_screen.dart';
import 'package:frb_code/ui/editor_screen.dart';
import 'package:frb_code/src/rust/frb_generated.dart';
import 'package:frb_code/tools/fonts_tools.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:frb_code/ui/lists/item_list_screen.dart';
import 'package:frb_code/ui/lists/contents_screen.dart';

import 'dart:io';
import 'package:frb_code/tools/folder_permission.dart';
// import 'package:frb_code/tools/fonts_tools.dart';


// import 'package:frb_code/ui/utils/settings_screen.dart';
// import 'package:frb_code/ui/utils/add_feed_screen.dart';
// import 'package:frb_code/ui/home_scaffold.dart';


void main() async {
  Logger logger = Logger(
    level: Level.all,
    filter: null,
    printer: PrettyPrinter(),
    output: ConsoleOutput(),
  );

  logger.i('application started');

  WidgetsFlutterBinding.ensureInitialized();

  await loadFonts();
  adjustWindow();
  await RustLib.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => RssProvider(),
      child: const MyApp(),
    ),
  );
}

void adjustWindow() {
  if (isDesktop) {
    doWhenWindowReady(() {
      final window = appWindow;
      window.minSize = const Size(400, 400);
      window.alignment = Alignment.center;
      window.title = 'Read and Write';

      if (Platform.isLinux) {
        const channel = MethodChannel('flutter/platform');
        channel.invokeMethod('Window.setSize', {'width': 432, 'height': 768});
      } else {
        window.size = const Size(432, 768);
      }

      window.show();
    });
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Read and Write',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)
    );
  }
}

// Root route content
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
body: Center(
        child: TextButton(
          onPressed: () => context.go('/b'),
          child: const Text('Go to another Screen'),
        ),
      ),
    );
  }
}

class LayoutModeProvider with ChangeNotifier {
  bool isSingleScreenMode = true;

  void toggleLayoutMode() {
    isSingleScreenMode = !isSingleScreenMode;
    notifyListeners();
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutMode = Provider.of<LayoutModeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout'),
        actions: [
          IconButton(
            icon: Icon(layoutMode.isSingleScreenMode ? Icons.grid_view : Icons.fullscreen),
            onPressed: () => layoutMode.toggleLayoutMode(),
          ),
        ],
      ),
      body: layoutMode.isSingleScreenMode ? const SingleScreenLayout() : const MultiScreenLayout(),
    );
  }
}

class SingleScreenLayout extends StatelessWidget {
  const SingleScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GoRouter.of(context).routerDelegate.currentConfiguration.fullPath == '/a'
        ? const BookScreen()
        : GoRouter.of(context).routerDelegate.currentConfiguration.fullPath == '/b'
            ? const RssScreen()
            : const EditorScreen();
  }
}

class MultiScreenLayout extends StatelessWidget {
  const MultiScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: BookScreen()),
        Expanded(child: RssScreen()),
        Expanded(child: EditorScreen()),
      ],
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/b',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/layout',
      builder: (context, state) => const ResponsiveLayout(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            GoRoute(
              path: '/a',
              builder: (context, state) => const BookScreen(),
              // routes: [
              //   GoRoute(
              //     path: 'a2',
              //     // builder: (context, state) => const ScreenA2(),
              //     routes: [
              //       GoRoute(
              //         path: 'a3',
              //         // builder: (context, state) => const ScreenA3(),
              //       ),
              //     ],
              //   ),
              // ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            GoRoute(
              path: '/b',
              builder: (context, state) => const RssScreen(),
              routes: [
                GoRoute(
                  path: 'b2',
                  builder: (context, state) {
                    return const ItemListScreen();
                  },
                  routes: [
                    GoRoute(
                      path: 'b3',
                      builder: (context, state) {
                        // final itemUrl = state.pathParameters['itemUrl']!;
                        // final title = state.pathParameters['title']!;
                        // final publishedAt = state.pathParameters['publishedAt']!;

                        return const ContentsScreen(
                          // url: itemUrl,
                          // title: title,
                          // publishedAt: publishedAt,
                          );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCKey,
          routes: [
            GoRoute(
              path: '/c',
              builder: (context, state) => const EditorScreen(),
          //     routes: [
          //       GoRoute(
          //         path: 'c2',
          //         // builder: (context, state) => const ScreenC2(),
          //         routes: [
          //           GoRoute(
          //             path: 'c3',
          //             // builder: (context, state) => const ScreenC3(),
          //           ),
          //         ],
          //       ),
          //     ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Book'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'RSS'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Editor'
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }
}

// BottomNavigationBarItem buildCustomBottomNavigationBarItem({
//   required String label,
//   required Icon icon,
//   int maxLines = 1,
// }) {
//   return BottomNavigationBarItem(
//     icon: icon,
//     label: null, // 置空默认标签
//     // 使用 `RichText` 作为标签
//     title: buildRichTextWithMaxLines(
//       text: label,
//       fontSize: 14.0,
//       maxLines: maxLines,
//     ),
//   );
// }



// 2

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:logger/logger.dart';

// import 'package:frb_code/models/rss_provider.dart';
// import 'package:frb_code/ui/book_screen.dart';
// import 'package:frb_code/ui/rss_screen.dart';
// import 'package:frb_code/ui/editor_screen.dart';
// import 'package:frb_code/src/rust/frb_generated.dart';
// import 'package:frb_code/tools/fonts_tools.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:frb_code/ui/lists/item_list_screen.dart';
// import 'package:frb_code/ui/lists/contents_screen.dart';

// import 'dart:io';
// import 'package:frb_code/tools/folder_permission.dart';


// // import 'package:frb_code/ui/utils/settings_screen.dart';
// // import 'package:frb_code/ui/utils/add_feed_screen.dart';
// // import 'package:frb_code/ui/home_scaffold.dart';


// void main() async {
//   Logger logger = Logger(
//     level: Level.all,
//     filter: null,
//     printer: PrettyPrinter(),
//     output: ConsoleOutput(),
//   );

//   logger.i('application started');

//   WidgetsFlutterBinding.ensureInitialized();

//   await loadFonts();
//   adjustWindow();
//   await RustLib.init();

//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => RssProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// void adjustWindow() {
//   if (isDesktop) {
//     doWhenWindowReady(() {
//       final window = appWindow;
//       window.minSize = const Size(400, 400);
//       window.alignment = Alignment.center;
//       window.title = 'Read and Write';

//       if (Platform.isLinux) {
//         const channel = MethodChannel('flutter/platform');
//         channel.invokeMethod('Window.setSize', {'width': 432, 'height': 768});
//       } else {
//         window.size = const Size(432, 768);
//       }

//       window.show();
//     });
//   }
// }


// final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
// final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
// final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');

// final _router = GoRouter(
//   navigatorKey: _rootNavigatorKey,
//   initialLocation: '/b',
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const WelcomeScreen(),
//     ),
//     StatefulShellRoute.indexedStack(
//       builder: (context, state, navigationShell) {
//         return ScaffoldWithNavBar(navigationShell: navigationShell);
//       },
//       branches: [
//         StatefulShellBranch(
//           navigatorKey: _shellNavigatorAKey,
//           routes: [
//             GoRoute(
//               path: '/a',
//               builder: (context, state) => const BookScreen(),
//               // routes: [
//               //   GoRoute(
//               //     path: 'a2',
//               //     // builder: (context, state) => const ScreenA2(),
//               //     routes: [
//               //       GoRoute(
//               //         path: 'a3',
//               //         // builder: (context, state) => const ScreenA3(),
//               //       ),
//               //     ],
//               //   ),
//               // ],
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigatorBKey,
//           routes: [
//             GoRoute(
//               path: '/b',
//               builder: (context, state) => const RssScreen(),
//               routes: [
//                 GoRoute(
//                   path: 'b2/:feedUrl',
//                   builder: (context, state) {
//                     final feedUrl = state.pathParameters['feedUrl']!;
//                     return ItemListScreen(feedUrl: feedUrl);
//                   },
//                   routes: [
//                     GoRoute(
//                       path: 'b3/:itemUrl',
//                       builder: (context, state) {
//                         final itemUrl = state.pathParameters['itemUrl']!;
//                         final title = state.pathParameters['title']!;
//                         final publishedAt = state.pathParameters['publishedAt']!;

//                         return ContentsScreen(
//                           url: itemUrl,
//                           title: title,
//                           publishedAt: publishedAt,
//                           );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//         StatefulShellBranch(
//           navigatorKey: _shellNavigatorCKey,
//           routes: [
//             GoRoute(
//               path: '/c',
//               builder: (context, state) => const EditorScreen(),
//           //     routes: [
//           //       GoRoute(
//           //         path: 'c2',
//           //         // builder: (context, state) => const ScreenC2(),
//           //         routes: [
//           //           GoRoute(
//           //             path: 'c3',
//           //             // builder: (context, state) => const ScreenC3(),
//           //           ),
//           //         ],
//           //       ),
//           //     ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   ],
// );

// class ScaffoldWithNavBar extends StatelessWidget {
//   const ScaffoldWithNavBar({
//     Key? key,
//     required this.navigationShell,
//   }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

//   final StatefulNavigationShell navigationShell;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: navigationShell,
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.book), label: 'A'),
//           BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'B'),
//           BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'C'),
//         ],
//         currentIndex: navigationShell.currentIndex,
//         selectedItemColor: Colors.amber[800],
//         onTap: (int index) => _onTap(context, index),
//       ),
//     );
//   }

//   void _onTap(BuildContext context, int index) {
//     navigationShell.goBranch(index,
//         initialLocation: index == navigationShell.currentIndex);
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//       title: 'Read and Write',
//       theme: ThemeData.light(), // Light theme
//       darkTheme: ThemeData.dark(), // Dark theme
//       themeMode: ThemeMode.system, // Use system theme mode (light/dark)
//     );
//   }
// }

// // Root route content
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Welcome')),
// body: Center(
//         child: TextButton(
//           onPressed: () => context.go('/b/'),
//           child: const Text('Go to RSS Screen'),
//         ),
//       ),
//     );
//   }
// }

// 1

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';

// import 'package:frb_code/src/rust/frb_generated.dart';
// import 'package:frb_code/models/rss_provider.dart';

// import 'package:frb_code/ui/home_screen.dart';
// import 'package:frb_code/tools/folder_permission.dart';
// import 'package:frb_code/tools/fonts_tools.dart';

// void main() async {
//   // 设置日志记录器
//   Logger logger = Logger(
//     level: Level.all,
//     filter: null,
//     printer: PrettyPrinter(),
//     output: ConsoleOutput(),
//   );

//   logger.i('application started');
  
//   WidgetsFlutterBinding.ensureInitialized();

//   await loadFonts();
//   adjustWindow();

//   await RustLib.init();

//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => RssProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// void adjustWindow() {
  
//   if (isDesktop) {
//     // Initialize window settings
//     doWhenWindowReady(() {
//       final window = appWindow;
//       window.minSize = const Size(400, 400);
//       window.alignment = Alignment.center;
//       window.title = 'Read and Write';
  
//       if (Platform.isLinux) {
//         const channel = MethodChannel('flutter/platform');
//         channel.invokeMethod('Window.setSize', {'width': 432, 'height': 768});
//       } else {
//         window.size = const Size(432, 768);
//       }
  
//       window.show();
//     });
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Read and Write',
//       theme: ThemeData.light(), // Light theme
//       darkTheme: ThemeData.dark(), // Dark theme
//       themeMode: ThemeMode.system, // Use system theme mode (light/dark)
//       home: const HomeScreen(),
//     );
//   }
// }