import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'app/dev_client_repository.dart';
import 'app/dev_request_handler.dart';
import 'app/endpoint_repository.dart';
import 'app/endpoint_request_handler.dart';
import 'app/endpoint_server.dart';
import 'app/dev_server.dart';
import 'app/endpoint_server_presenter.dart';
import 'app/selected_endpoint_presenter.dart';

import 'core/endpoint.dart';

import 'ui/models/selectable_endpoint.dart';

class App {
  final EndpointRepository endpointRepository = EndpointRepository([]);
  final WsClientConnectionRepository wsClientConnectionRepository = WsClientConnectionRepository([]);

  late EndpointRequestHandler endpointRequestHandler;
  late EndpointServer endpointServer;

  late DevRequestHandler requestHandler;
  late DevServer devServer;

  late EndpointServerPresenter endpointServerPresenter;
  late SelectedEndpointPresenter selectedEndpointPresenter;

  App() {
    endpointRequestHandler = EndpointRequestHandler(endpointRepository);
    endpointServer = EndpointServer(endpointRequestHandler, config: EndpointServerConfig(port: 8080));

    requestHandler = DevRequestHandler(wsClientConnectionRepository, endpointRepository);
    devServer = DevServer(requestHandler, config: DevServerConfig(port: 8081));

    endpointServerPresenter = EndpointServerPresenter(endpointServer);
    selectedEndpointPresenter = SelectedEndpointPresenter();
  }

  initPresenterObservables() {
    endpointServerPresenter.init();
    selectedEndpointPresenter.init();
  }

  initDevServer() {
    devServer.listen();
  }

  Stream<Endpoint?> get selectedEndpointObserver => Rx.combineLatest2<Endpoint?, EndpointRepository, Endpoint?>(
      selectedEndpointPresenter.stream,
      endpointRepository.stream,
      (point, repo) => repo.list.contains(point) ? point : null);

  Stream<List<SelectableEndpoint>> get selectableEndpointListObserver =>
      Rx.combineLatest2<Endpoint?, EndpointRepository, List<SelectableEndpoint>>(
          selectedEndpointPresenter.stream,
          endpointRepository.stream,
          (a, b) => b.list.map((endpoint) => SelectableEndpoint(endpoint, endpoint == a)).toList());
}
