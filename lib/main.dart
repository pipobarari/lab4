import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lab4flutter/widgets/location.dart';
import 'dart:io';
import 'package:app_links/app_links.dart';
// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

// import 'web_url_protocol.dart'
//     if (dart.library.io) 'package:url_protocol/url_protocol.dart';

// void main() {
//   // SecurityContext serverContext = SecurityContext()
//   //   ..useCertificateChain('certificate.pem')
//   //   ..usePrivateKey('key.pem');

//   // // Bind the server to an address and port
//   // HttpServer server =
//   //     await HttpServer.bindSecure('localhost', 443, serverContext);

//   // // ...
//   // // Rest of your code

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   void init() async {
//     final appLinks = AppLinks();

// // Get the initial/first link.
// // This is useful when app was terminated (i.e. not started)
//     final uri = await appLinks.getInitialAppLink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           title: Text(widget.title),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const Text(
//                 'You have pushed the button this many times:',
//               ),
//               Text(
//                 '$_counter',
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//               LocationWidget()
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _incrementCounter,
//           tooltip: 'Increment',
//           child: const Icon(Icons.add),
//         ));
//   }
// }
const kWindowsScheme = 'sample';

void main() {
  // Register our protocol only on Windows platform
  // _registerWindowsProtocol();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      print('getInitialAppLink: $appLink');
      openAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        // Mimic web routing
        final routeName = settings.name;
        if (routeName != null) {
          if (routeName.startsWith('/book/')) {
            // Navigated to /book/:id
            routeWidget = customScreen(
              routeName.substring(routeName.indexOf('/book/')),
            );
          } else if (routeName == '/book') {
            // Navigated to /book without other parameters
            routeWidget = customScreen("None");
          }
        }

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const
            SelectableText('''
            Launch an intent to get to the second screen.

            On web:
            http://localhost:38751/#/book/1 for example.

            On windows & macOS, open your browser:
            sample://foo/#/book/hello-deep-linking

            This example code triggers new page from URL fragment.
            '''),
            // const
            SizedBox(height: 20),
            // buildWindowsUnregisterBtn(),
          ],
        ),
      ),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(child: Text('Opened with parameter: $bookId')),
    );
  }

  // Widget buildWindowsUnregisterBtn() {
  //   if (!kIsWeb) {
  //     if (Platform.isWindows) {
  //       return TextButton(
  //           onPressed: () => unregisterProtocolHandler(kWindowsScheme),
  //           child: const Text('Remove Windows protocol registration'));
  //     }
  //   }

  //   return const SizedBox.shrink();
  // }
}

// void _registerWindowsProtocol() {
//   // Register our protocol only on Windows platform
//   if (!kIsWeb) {
//     if (Platform.isWindows) {
//       registerProtocolHandler(kWindowsScheme);
//     }
//   }
// }
