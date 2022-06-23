// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:enderpoint/app/endpoint_repository.dart';
import 'package:enderpoint/core/flavor.dart';

import '../core/endpoint.dart';
import 'dev_client_connection.dart';
import 'dev_client_repository.dart';

class DevRequestHandler {
  final WsClientConnectionRepository clientRepo;
  final EndpointRepository endpointRepo;

  DevRequestHandler(this.clientRepo, this.endpointRepo);

  void _handleClientEvent(event, WsClientConnection client) {
    try {
      var dEvent = json.decode(event);
      switch (dEvent["event"]) {
        case "create-endpoint":
          {
            Endpoint endpoint = EndpointHelper.endpointFromJson(dEvent['payload']);
            endpointRepo.add(endpoint);
            break;
          }
      }
    } catch (err) {
      print(err);
    }
  }

  void _handleClient(WsClientConnection client) {
    clientRepo.add(client);
    client.socket.listen((event) => _handleClientEvent(event, client), onDone: () {
      client.socket.close();
      clientRepo.remove(client);
    });
  }

  void _handleWebsocketConnection(HttpRequest request) async {
    WebSocket socket = await WebSocketTransformer.upgrade(request);
    _handleClient(WsClientConnection(socket: socket, request: request));
  }

  void handleHttpRequest(HttpRequest request) {
    if (request.headers.value('connection') == 'Upgrade') {
      _handleWebsocketConnection(request);
    }
  }
}

class EndpointHelper {
  static flavorFormJson(dynamic data) {
    return Flavor(identifier: data["id"], statusCode: data["statusCode"], body: data["body"]);
  }

  static Endpoint endpointFromJson(dynamic data) {
    return Endpoint(data["id"], data["flavors"].map<Flavor>((flavor) => flavorFormJson(flavor)).toList(), data["url"]);
  }
}
