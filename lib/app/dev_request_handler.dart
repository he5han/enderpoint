// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:enderpoint/app/endpoint_bootstraper.dart';
import 'package:uuid/uuid.dart';

import '../app/dev_notification_handler.dart';
import '../app/endpoint_repository.dart';
import '../core/endpoint.dart';

import 'dev_client_connection.dart';
import 'dev_client_repository.dart';

class DevWsResponse {
  static const ok = "OK";

  late WsClientConnection connection;
  late String requestId;
  late String action;
  late dynamic body;

  DevWsResponse() : body = {};

  close() {
    connection.socket.add(
        DevNotification(id: const Uuid().v1(), action: "dev:response", payload: {"requestId": requestId, "body": body})
            .toString());
  }
}

class DevRequestHandler {
  final WsClientConnectionRepository clientRepo;
  final EndpointRepository endpointRepo;

  DevRequestHandler(this.clientRepo, this.endpointRepo);

  void _handleClientEvent(event, WsClientConnection connection) {
    try {
      var dEvent = json.decode(event);
      DevWsResponse response = DevWsResponse()
        ..connection = connection
        ..requestId = dEvent["id"];

      switch (dEvent["event"]) {
        case "endpoint:create":
          {
            Endpoint endpoint = Endpoint.fromJson(dEvent['payload']);
            endpointRepo.add(endpoint);
            response.body = "OK";
            break;
          }
        case "endpoint:update":
          {
            try {
              Endpoint endpoint = Endpoint.fromJson(dEvent['payload']);
              endpointRepo.update(dEvent['payload']["id"], endpoint);
              response.body = "OK";
            } catch (_) {
              response.body = {"error": "Not found"};
            }

            break;
          }
        case "endpoint:delete":
          {
            try {
              endpointRepo.remove(dEvent['payload']["id"]);
              response.body = "OK";
            } catch (_) {
              response.body = {"error": "Not found"};
            }
            break;
          }
        case "endpoint:bootstrap":
          {
            try {
              response.body = EndpointBootstraper.bootstrap().toJson();
            } catch (_) {
              response.body = {"error": "Not found"};
            }
            break;
          }
        default:
          {
            response.body = {"error": "Method '${dEvent["event"]}' not found"};
            break;
          }
      }

      response.close();
    } catch (err) {
      print(err);
    }
  }

  void _handleDisconnect(WsClientConnection client) {
    client.socket.close();

    clientRepo.remove(client);
  }

  void _handleClientConnect(WsClientConnection client) {
    client.socket.listen((event) => _handleClientEvent(event, client), onDone: () => _handleDisconnect(client));
    client.socket.add(DevNotification(id: const Uuid().v1(), action: "dev:greet", payload: "Welcome!").toString());

    clientRepo.add(client);
  }

  void _handleWebsocketConnection(HttpRequest request) async {
    WebSocket socket = await WebSocketTransformer.upgrade(request);
    _handleClientConnect(WsClientConnection(socket: socket, request: request));
  }

  void handleHttpRequest(HttpRequest request) {
    if (request.headers.value('connection') == 'Upgrade') {
      _handleWebsocketConnection(request);
    }
  }
}
