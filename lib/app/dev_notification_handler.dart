import 'dart:convert';

import 'package:enderpoint/app/dev_client_connection.dart';

import 'dev_ws_broadcaster.dart';

class DevNotification {
  String id;
  String action;
  dynamic payload;

  DevNotification({required this.id, required this.action, required this.payload});

  @override
  String toString() {
    return jsonEncode({"id": id, "action": action, "payload": payload});
  }
}

class DevNotificationHandler {
  final WsBroadcaster broadcaster;

  DevNotificationHandler({required this.broadcaster});

  void setConnections(List<WsClientConnection> connections){
    broadcaster.connections = connections;
  }

  notifyAll(DevNotification notification) {
    broadcaster.broadcast(notification.toString());
  }
}
