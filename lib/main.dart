import 'dart:math';

import 'package:enderpoint/app/endpoint_server_view_service.dart';

import 'core/flavor.dart';
import 'core/endpoint.dart';

import 'app/endpoint_collection.dart';
import 'app/endpoint_request_handler.dart';
import 'app/endpoint_view_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  List<Provider> getProviders() {
    EndpointCollection collection = EndpointCollection([]);
    EndpointRequestHandler requestHandler = EndpointRequestHandler(collection);

    return [
      Provider<EndpointViewService>(create: (_) => EndpointViewService(collection.list)..init()),
      Provider<EndpointServerViewService>(
          create: (_) => EndpointServerViewService(EndpointServerHandler(requestHandler))..init())
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
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

  Endpoint createRandomEndpoint(List<Endpoint> endpoints) {
    int rNum = Random().nextInt(100);
    //
    // Endpoint tmp = Endpoint(
    //     rNum,
    //     [
    //       Flavor(identifier: 0x00, body: {"msg": "hello world"}, statusCode: 200),
    //       Flavor(identifier: 0x02, body: {"msg": "Error"}, statusCode: 500)
    //     ],
    //     "/test-$rNum");
    //
    // if (endpoints.contains(tmp)) {
    //   tmp = createRandomEndpoint(endpoints);
    // }
    //
    // return tmp;

    return Endpoint(
        rNum,
        [
          Flavor(identifier: 0x00, body: {"msg": "hello world"}, statusCode: 200),
          Flavor(identifier: 0x02, body: {"msg": "Error"}, statusCode: 500),
        ],
        "/test-$rNum");
  }

  @override
  Widget build(BuildContext context) {
    EndpointViewService endpointViewService = Provider.of<EndpointViewService>(context);
    EndpointServerViewService endpointServerViewService = Provider.of<EndpointServerViewService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
              onPressed: () {
                endpointViewService.addEndpoint(createRandomEndpoint(endpointViewService.getCurrentSync().endpoints));
              },
              child: const Text("Add Endpoint")),
          StreamBuilder<EndpointServerViewModel>(
            stream: endpointServerViewService.observable,
            builder: (context, snapshot) => Visibility(
              visible: snapshot.data != null && snapshot.data!.state == ServerState.closed,
              child: TextButton(
                  onPressed: () {
                    endpointServerViewService.start();
                  },
                  child: const Text("Start server")),
              replacement: TextButton(
                  onPressed: () {
                    endpointServerViewService.stop();
                  },
                  child: const Text("Destroy server")),
            ),
          ),
          Expanded(
            child: StreamBuilder<EndpointViewModel>(
                stream: endpointViewService.observable,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: (snapshot.data!.endpoints)
                          .map((endpoint) => EndpointCard(
                                endpoint: endpoint,
                                isSelected: snapshot.data!.selectedEndpoint == endpoint,
                                onSelect: () => endpointViewService.setSelectedEndpoint(endpoint),
                                onFlavorSelect: (flavor) => endpointViewService.setFlavor(endpoint, flavor),
                                onRemove: () => endpointViewService.removeEndpoint(endpoint),
                              ))
                          .toList(),
                      shrinkWrap: true,
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
  final bool isSelected;

  final Function(Flavor) onFlavorSelect;
  final Function() onRemove;
  final Function() onSelect;

  const EndpointCard(
      {Key? key,
      required this.endpoint,
      required this.onFlavorSelect,
      required this.onRemove,
      required this.onSelect,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => onSelect(),
            child: Row(
              children: [
                Expanded(child: Text(endpoint.url)),
                TextButton(onPressed: () => onRemove(), child: const Text("x"))
              ],
            ),
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
      ),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: isSelected ? Theme.of(context).primaryColor : Colors.transparent)),
    );
  }
}
