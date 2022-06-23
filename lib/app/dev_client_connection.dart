import 'dart:io';

class WsClientConnection {
  WebSocket socket;
  HttpRequest request;

  WsClientConnection({required this.socket, required this.request});

  String? get address => request.connectionInfo?.remoteAddress.address;
}
