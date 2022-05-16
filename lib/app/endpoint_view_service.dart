import 'dart:async';
import 'dart:io';

import 'package:enderpoint/app/endpoint_collection.dart';
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
  final EndpointCollection _endpointCollection;

  late BehaviorSubject<EndpointViewModel> endpointViewObservable;

  late HttpServer _server;
  late EndpointViewModel _viewModel;
  late StreamSubscription _serverSubscription;

  EndpointViewService(List<Endpoint> initialEndpoints) : _endpointCollection = EndpointCollection(initialEndpoints);

  _notifyEndpointObservable(EndpointViewModel model) {
    endpointViewObservable.add(model);
  }

  setFlavor(Endpoint endpoint, Flavor flavor) {
    endpoint.flavor = flavor;
    _viewModel.endpoints = _endpointCollection.list;
    _notifyEndpointObservable(_viewModel);
  }

  addEndpoint(Endpoint endpoint) {
    _endpointCollection.list.add(endpoint);
    _viewModel.endpoints = _endpointCollection.list;
    _notifyEndpointObservable(_viewModel);
  }

  removeEndpoint(Endpoint endpoint) {
    _endpointCollection.list.remove(endpoint);
    _viewModel.endpoints = _endpointCollection.list;
    _notifyEndpointObservable(_viewModel);
  }

  start() async {
    try {
      EndpointRequestHandler requestHandler = EndpointRequestHandler(_endpointCollection);
      _serverSubscription = _server.listen(requestHandler.handleHttpRequest, onDone: () => stop());
    } on Error {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
      await start();
    }

    _viewModel.state = ServerState.idle;
    _notifyEndpointObservable(_viewModel);

    return;
  }

  stop() async {
    await _serverSubscription.cancel();
    await _server.close(force: true);
    _viewModel.state = ServerState.closed;
    _notifyEndpointObservable(_viewModel);
  }

  init() {
    _viewModel = EndpointViewModel([], ServerState.closed);
    endpointViewObservable = BehaviorSubject<EndpointViewModel>.seeded(_viewModel);
  }
}
