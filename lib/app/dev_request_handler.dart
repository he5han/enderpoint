// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:enderpoint/app/endpoint_repository.dart';
import 'package:enderpoint/core/flavor.dart';

import '../core/endpoint.dart';
import 'dev_client.dart';
import 'dev_client_repository.dart';

class DevRequestHandler {
  final DevClientRepository clientRepo;
  final EndpointRepository endpointRepo;

  DevRequestHandler(this.clientRepo, this.endpointRepo);

  _handleClientEvent(event, WsClient client) {
    try {
      var dEvent = json.decode(event);
      if (dEvent["event"] == "create-endpoint") {
        var payload = dEvent['payload'];
        Endpoint endpoint = Endpoint(
            payload["id"],
            payload["flavors"]
                .map<Flavor>((flavor) =>
                    Flavor(identifier: flavor["id"], statusCode: flavor["statusCode"], body: flavor["body"]))
                .toList(),
            payload["url"]);
        endpointRepo.add(endpoint);
      }
    } catch (err) {
      print(err);
    }
  }

  _handleClient(WsClient client) {
    clientRepo.add(client);
    client.socket.listen((event) => _handleClientEvent(event, client), onDone: () {
      client.socket.close();
      clientRepo.remove(client);
    });
  }

  void _handleWebsocketConnection(HttpRequest request) async {
    WebSocket socket = await WebSocketTransformer.upgrade(request);
    _handleClient(WsClient(socket: socket, request: request));
  }

  handleHttpRequest(HttpRequest request) {
    if (request.headers.value('connection') == 'Upgrade') {
      _handleWebsocketConnection(request);
    }
  }
}
