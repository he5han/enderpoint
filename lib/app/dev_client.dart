import 'dart:io';

class WsClient {
  WebSocket socket;
  HttpRequest request;

  WsClient({required this.socket, required this.request});

  String? get address => request.connectionInfo?.remoteAddress.address;
}
