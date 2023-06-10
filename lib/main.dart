import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lab4flutter/widgets/location.dart';
import 'package:lab4flutter/widgets/custom_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:lab4flutter/widgets/screen_arguments.dart';

void main() {
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
        Widget routeWidget = const MyHomePage(
          title: 'Lab4',
        );

        // Mimic web routing
        final routeName = settings.name;
        if (routeName != null) {
          var url = Uri.dataFromString(routeName);
          Map<String, String> params = url.queryParameters;
          // var latitude = params['latitude'] as String;
          // print(latitude);
          if (routeName.startsWith('/location/')) {
            routeWidget = customScreen(params);
          }
        } else if (routeName == '/location') {
          // Navigated to /book without other parameters
          // ScreenArguments arguments = ScreenArguments('algo');
          routeWidget = customScreen({"algo": "algo"});
        }
        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[LocationWidget()],
        ),
      ),
    );
  }
}
