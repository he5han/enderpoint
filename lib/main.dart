import 'package:enderpoint/ui/theme.dart';
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

  final ThemeProvider themeProvider = ThemeProvider();

  initApp() {
    app.initPresenterObservables();
    app.initDevServer();
  }

  @override
  Widget build(BuildContext context) {
    initApp();

    return ChangeNotifierProvider(
        create: (_) => themeProvider,
        builder: (context, _) {
          return MultiProvider(
            providers: [Provider<enderpoint.App>(create: (_) => app)],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Enderpoint',
              theme: Provider.of<ThemeProvider>(context).theme,
              home: const MainPage(),
            ),
          );
        });
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Main Controls"),),
        body: Container(
          color: Colors.white,
            child: const SafeArea(child: ControlPanel()), padding: const EdgeInsets.symmetric(horizontal: 10)));
  }
}
