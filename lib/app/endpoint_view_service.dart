import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../core/flavor.dart';
import '../core/endpoint.dart';
import '../app/endpoint_request_handler.dart';

enum ServerState { closed, idle }

class EndpointViewModel {
  List<Endpoint> endpoints;
  ServerState state;

  EndpointViewModel(this.endpoints, this.state);
}

class EndpointViewService {
  final EndpointRequestHandler requestHandler;

  late HttpServer _server;

  late BehaviorSubject<EndpointViewModel> endpointViewObservable;
  late EndpointViewModel _viewModel;
  late StreamSubscription serverSubscription;

  EndpointViewService(this.requestHandler);

  _notifyEndpointObservable(EndpointViewModel model) {
    endpointViewObservable.add(model);
  }

  setFlavor(Endpoint endpoint, Flavor flavor) {
    endpoint.flavor = flavor;
    _viewModel.endpoints = requestHandler.endpoints;
    _notifyEndpointObservable(_viewModel);
  }

  addEndpoint(Endpoint endpoint) {
    requestHandler.endpoints.add(endpoint);
    _viewModel.endpoints = requestHandler.endpoints;
    _notifyEndpointObservable(_viewModel);
  }

  removeEndpoint(Endpoint endpoint) {
    requestHandler.endpoints.remove(endpoint);
    _viewModel.endpoints = requestHandler.endpoints;
    _notifyEndpointObservable(_viewModel);
  }

  start() async {
    try {
      serverSubscription = _server.listen(requestHandler.handleHttpRequest);
    } on Error {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
      await start();
    }

    _viewModel.state = ServerState.idle;
    _notifyEndpointObservable(_viewModel);

    return;
  }

  stop() async {
    await serverSubscription.cancel();
    await _server.close(force: true);
    _viewModel.state = ServerState.closed;
    _notifyEndpointObservable(_viewModel);
  }

  init() {
    _viewModel = EndpointViewModel([], ServerState.closed);
    endpointViewObservable = BehaviorSubject<EndpointViewModel>.seeded(_viewModel);
  }
}
