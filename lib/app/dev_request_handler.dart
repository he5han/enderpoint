// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../app/endpoint_bootstraper.dart';
import '../app/dev_notification_handler.dart';
import '../app/endpoint_repository.dart';
import '../core/flavor.dart';
import '../core/endpoint.dart';

import 'dev_client_connection.dart';
import 'dev_client_repository.dart';

typedef ApiMethod<T> = T Function(HttpRequest, Map<String, dynamic>);

class DevRequestHandler {
  final EndpointRepository endpointRepo;
  final WsHandler _wsHandler;
  final Map<String, ApiMethod> _devAPIs;

  DevRequestHandler(WsClientConnectionRepository clientRepo, this.endpointRepo)
      : _wsHandler = WsHandler(clientRepo),
        _devAPIs = {
          "/v1/endpoint/create": (request, data) {
            Endpoint endpoint = Endpoint.fromJson(data);
            endpointRepo.add(endpoint);
            return request.response
              ..statusCode = HttpStatus.ok
              ..write("OK");
          },
          "/v1/endpoint/update": (request, data) {
            Endpoint endpoint = Endpoint.fromJson(data['payload']);
            endpointRepo.update(data['payload']["id"], endpoint);
            return request.response
              ..statusCode = HttpStatus.ok
              ..write("OK");
          },
          "/v1/endpoint/delete": (request, data) {
            endpointRepo.remove(data['payload']["id"]);
            return request.response
              ..statusCode = HttpStatus.ok
              ..write("OK");
          },
          "/v1/endpoint/bootstrap": (request, data) {
            return request.response
              ..headers.contentType = ContentType.json
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(EndpointBootstraper.bootstrap().toJson()));
          },
          "/v1/flavor/bootstrap": (request, data) {
            return request.response
              ..headers.contentType = ContentType.json
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode(FlavorBootstraper.bootstrap().toJson()));
          },
          "/v1/uuid/generate": (request, data) {
            return request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode({"version": "v1", "uuid": const Uuid().v1()}));
          }
        };

  void _handleRequest(HttpRequest request) async {
    try {
      Uint8List data = await request.reduce((previous, element) => previous..addAll(element));
      Map<String, dynamic> decodedContent = jsonDecode(String.fromCharCodes(data));

      if (_devAPIs.containsKey(request.uri.path)) {
        _devAPIs[request.uri.path]!(request, decodedContent);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write("404 not found");
      }
    } catch (_error) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(_error.toString());
    }
    request.response.close();
  }

  void handleHttpRequest(HttpRequest request) {
    if (request.headers.value('connection') == 'Upgrade') {
      _wsHandler.handleUpgradeRequest(request, onEvent: (_, __) {});
    } else {
      _handleRequest(request);
    }
  }
}

typedef WsEventCallback = Function(WsClientConnection client, dynamic event);

class WsHandler {
  final WsClientConnectionRepository clientRepo;
  WsHandler(this.clientRepo);

  handleUpgradeRequest(HttpRequest request, {required WsEventCallback onEvent, Function? onError}) async {
    WebSocket socket = await WebSocketTransformer.upgrade(request);
    WsClientConnection client = WsClientConnection(socket: socket, request: request);

    client.socket.listen((event) => onEvent(client, event), onDone: () {
      client.socket.close();
      clientRepo.remove(client);
    });
    client.socket.add(DevNotification(id: const Uuid().v1(), action: "dev:greet", payload: "Welcome!").toString());
    clientRepo.add(client);
  }
}
