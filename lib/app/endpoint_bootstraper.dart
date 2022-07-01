import 'dart:io';

import 'package:uuid/uuid.dart';

import '../core/endpoint.dart';
import '../core/flavor.dart';

class EndpointBootstraper {
  static int _count = 0;

  static Endpoint bootstrap({String? url}) {
    return Endpoint(
        const Uuid().v1(),
        [
          Flavor(
              id: const Uuid().v1(),
              statusCode: HttpStatus.ok,
              headers: {"content-type": "text/html; charset=utf-8"},
              body: "<h1>😎</h1>"),
          Flavor(
              id: const Uuid().v1(),
              statusCode: HttpStatus.internalServerError,
              headers: {"content-type": "text/html; charset=utf-8"},
              body: "<h1>💀</h1>"),
        ],
        url ?? "/be${_count++}");
  }
}

class FlavorBootstraper {
  static Flavor bootstrap({String? url}) {
    return Flavor(
        id: const Uuid().v1(),
        statusCode: HttpStatus.ok,
        headers: {"content-type": "text/html; charset=utf-8"},
        body: "<h1>😎</h1>");
  }
}
