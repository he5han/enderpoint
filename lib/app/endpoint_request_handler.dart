import 'dart:convert';
import 'dart:io';

import '../core/endpoint.dart';
import 'endpoint_collection.dart';

class EndpointRequestHandler {
  final EndpointCollection endpointCollection;

  EndpointRequestHandler(this.endpointCollection);

  void _resolveRequest(HttpRequest request, Endpoint endpoint) {
    request.response
      ..headers.contentType = ContentType.json
      ..statusCode = endpoint.flavor.statusCode
      ..write(jsonEncode(endpoint.flavor.body))
      ..close();
  }

  handleHttpRequest(HttpRequest request) {
    try {
      Endpoint endpoint = endpointCollection.findByUrl(request.uri.toString());
      _resolveRequest(request, endpoint);
    } on StateError {
      request.response
        ..headers.contentType = ContentType.html
        ..statusCode = HttpStatus.notImplemented
        ..write("<h1>⚠️️ Enderpoint Error</h1><hr>")
        ..write("<code><b>501: Not Implemented</b></code><br>")
        ..write("<code>${request.uri}</code>")
        ..close();
    } catch (error) {
      request.response
        ..headers.contentType = ContentType.html
        ..statusCode = HttpStatus.internalServerError
        ..write("<h1>⚠️️ Enderpoint Error</h1><hr>")
        ..write("<code><b>500: Internal Server Error</b></code><br>")
        ..write("<code>${error.toString()}</code>")
        ..close();
    }
  }

  // List<Endpoint> get endpoints => endpointCollection.list;
}
