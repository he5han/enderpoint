import 'dart:io';

import '../core/endpoint.dart';
import '../core/flavor.dart';
import 'endpoint_repository.dart';

class EndpointRequestHandler {
  final EndpointRepository endpointCollection;

  EndpointRequestHandler(this.endpointCollection);

  void _resolveRequest(HttpRequest request, Endpoint endpoint) {
    if (endpoint.flavor == null) {
      throw Exception("Flavor not found");
    }

    Flavor flavor = endpoint.flavor!;
    if (flavor.headers != null) {
      for (var key in flavor.headers!.keys) {
        request.response.headers.set(key, flavor.headers![key]);
      }
    }

    request.response
      ..statusCode = endpoint.flavor!.statusCode
      ..write(endpoint.flavor!.body)
      ..close();
  }

  handleHttpRequest(HttpRequest request) {
    try {
      Endpoint? endpoint = endpointCollection.findByUrl(request.uri.toString());
      if (endpoint != null) {
        _resolveRequest(request, endpoint);
      }
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
