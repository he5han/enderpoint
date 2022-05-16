import './core/flavor.dart';
import './core/endpoint.dart';

import './app/endpoint_collection.dart';
import './app/endpoint_request_handler.dart';
import './app/endpoint_view_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EndpointViewService>(
            create: (_) => EndpointViewService([])..init())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EndpointViewService viewService = Provider.of<EndpointViewService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
              onPressed: () {
                viewService.start();
              },
              child: const Text("Start server")),
          TextButton(
              onPressed: () {
                viewService.stop();
              },
              child: const Text("Destroy server")),
          TextButton(
              onPressed: () {
                viewService.addEndpoint(Endpoint(
                    0xff,
                    [
                      Flavor(identifier: 0x00, body: {"msg": "hello world"}, statusCode: 200),
                      Flavor(identifier: 0x02, body: {"msg": "Error"}, statusCode: 500)
                    ],
                    "/test"));
              },
              child: const Text("Add Endpoint")),
          Expanded(
            child: StreamBuilder<EndpointViewModel>(
                stream: viewService.endpointViewObservable,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(snapshot.data!.state.toString()),
                        ListView(
                          children: (snapshot.data!.endpoints)
                              .map((endpoint) => EndpointCard(
                                    endpoint: endpoint,
                                    onFlavorSelect: (flavor) => viewService.setFlavor(endpoint, flavor),
                                    onRemove: () => viewService.removeEndpoint(endpoint),
                                  ))
                              .toList(),
                          shrinkWrap: true,
                        ),
                      ],
                    );
                  }
                  return const Text(":)");
                }),
          )
        ],
      ),
    );
  }
}

class EndpointCard extends StatelessWidget {
  final Endpoint endpoint;
  final Function(Flavor) onFlavorSelect;
  final Function onRemove;
  const EndpointCard({Key? key, required this.endpoint, required this.onFlavorSelect, required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(endpoint.url)),
            TextButton(onPressed: () => onRemove(), child: const Text("x"))
          ],
        ),
        Row(
            children: endpoint.flavors
                .map((e) => TextButton(
                    onPressed: () => onFlavorSelect(e),
                    child: Text(
                      e.statusCode.toString(),
                      style: TextStyle(color: e == endpoint.flavor ? Colors.black : Colors.grey),
                    )))
                .toList())
      ],
    );
  }
}
