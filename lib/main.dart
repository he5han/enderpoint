import 'package:enderpoint/app/dev_client_repository.dart';
import 'package:enderpoint/app/dev_request_handler.dart';
import 'package:enderpoint/app/dev_server.dart';
import 'package:enderpoint/ui/control_panel.dart';

import 'app/endpoint_repository.dart';
import 'app/endpoint_request_handler.dart';
import 'app/endpoint_server.dart';
import 'app/endpoint_server_presenter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/selected_endpoint_presenter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  List<Provider> getProviders() {
    EndpointRepository endpointRepository = EndpointRepository([]);
    DevClientRepository devClientRepository = DevClientRepository([]);

    EndpointRequestHandler endpointRequestHandler = EndpointRequestHandler(endpointRepository);
    EndpointServer endpointServer = EndpointServer(endpointRequestHandler, config: EndpointServerConfig(port: 8080));

    DevRequestHandler requestHandler = DevRequestHandler(devClientRepository, endpointRepository);
    DevServer devServer = DevServer(requestHandler, config: DevServerConfig(port: 8081));

    devServer.listen();

    return [
      Provider<EndpointRepository>(create: (_) => endpointRepository),
      Provider<DevClientRepository>(create: (_) => devClientRepository),
      Provider<EndpointServerPresenter>(create: (_) => EndpointServerPresenter(endpointServer)..init()),
      Provider<SelectedEndpointPresenter>(create: (_) => SelectedEndpointPresenter()..init()),
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
