import 'dart:async';
import 'dart:io';

import 'dev_request_handler.dart';

class DevServerConfig {
  final int port;

  DevServerConfig({required this.port});
}

class DevServer {
  DevServerConfig config;

  late HttpServer _server;
  late StreamSubscription _serverSubscription;
  final DevRequestHandler _requestHandler;

  DevServer(this._requestHandler, {required this.config});

  listen() async {
    try {
      _serverSubscription = _server.listen(_requestHandler.handleHttpRequest, onDone: () => cancel());
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
