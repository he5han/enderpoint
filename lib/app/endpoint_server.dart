import 'dart:async';
import 'dart:io';

import 'endpoint_request_handler.dart';

class EndpointServerConfig {
  final int port;

  EndpointServerConfig({required this.port});
}

class EndpointServer {
  EndpointServerConfig config;

  late HttpServer _server;
  late StreamSubscription _serverSubscription;
  final EndpointRequestHandler _requestHandler;

  EndpointServer(this._requestHandler, {required this.config});

  listen({Function()? onDone}) async {
    try {
      _serverSubscription = _server.listen(_requestHandler.handleHttpRequest, onDone: onDone);
    } on Error {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, config.port, shared: true);
      await listen();
    }
  }

  Future cancel() async {
    await _serverSubscription.cancel();
    await _server.close(force: true);
  }
}
