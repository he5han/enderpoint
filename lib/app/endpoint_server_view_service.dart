import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'endpoint_request_handler.dart';

enum ServerState { closed, idle }

class EndpointServerViewModel {
  ServerState state;

  EndpointServerViewModel({required this.state});
}

class EndpointServerViewService {
  final EndpointServerHandler serverHandler;

  late EndpointServerViewModel _viewModel;
  late BehaviorSubject<EndpointServerViewModel> observable;

  EndpointServerViewService(this.serverHandler);

  start() {
    serverHandler.listen();
    _viewModel.state = ServerState.idle;
    observable.add(_viewModel);
  }

  stop() async {
    await serverHandler.cancel();
    _viewModel.state = ServerState.closed;
    observable.add(_viewModel);
  }

  init() {
    _viewModel = EndpointServerViewModel(state: ServerState.closed);
    observable = BehaviorSubject<EndpointServerViewModel>.seeded(_viewModel);
  }
}

class EndpointServerHandler {
  late HttpServer _server;
  late StreamSubscription _serverSubscription;
  final EndpointRequestHandler _requestHandler;

  EndpointServerHandler(this._requestHandler);

  listen() async {
    try {
      _serverSubscription = _server.listen(_requestHandler.handleHttpRequest, onDone: () => cancel());
    } on Error {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
      await listen();
    }
  }

  Future cancel() async {
    await _serverSubscription.cancel();
    await _server.close(force: true);
  }
}
