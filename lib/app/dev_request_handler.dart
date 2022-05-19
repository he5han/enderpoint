// ignore_for_file: avoid_print

import 'dart:io';

import 'dev_client.dart';
import 'dev_client_repository.dart';

class DevRequestHandler {
  final DevClientRepository clientRepo;

  DevRequestHandler(this.clientRepo);

  _handleClient(DevClient client) {
    clientRepo.add(client);
    client.socket.listen((event) {
      print(event);
    }, onDone: () {
      client.socket.close();
      clientRepo.remove(client);
    });
  }

  void _handleWebsocketConnection(HttpRequest request) async {
    WebSocket socket = await WebSocketTransformer.upgrade(request);
    _handleClient(DevClient(socket: socket, connectionInfo: request.connectionInfo, session: request.session));
  }

  handleHttpRequest(HttpRequest request) {
    if (request.headers.value('connection') == 'Upgrade') {
      _handleWebsocketConnection(request);
    }
  }
}
