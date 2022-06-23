import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart' as enderpoint;

import 'package:enderpoint/ui/control_panel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final enderpoint.App app = enderpoint.App();
  MyApp({Key? key}) : super(key: key);

  List<Provider> getProviders() {
    app.initPresenterObservables();
    app.initDevServer();

    return [
      Provider<enderpoint.App>(create: (_) => app),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MaterialApp(
        title: 'Enderpoint',
        theme: ThemeData(primaryColor: Colors.black),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: const SafeArea(child: ControlPanel()), padding: const EdgeInsets.symmetric(horizontal: 10)));
  }
}
