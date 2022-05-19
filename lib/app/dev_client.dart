import 'dart:io';

class DevClient {
  WebSocket socket;
  HttpConnectionInfo? connectionInfo;
  HttpSession session;

  DevClient({required this.socket, required this.session, this.connectionInfo});

  String? get address => connectionInfo?.remoteAddress.address;
}
