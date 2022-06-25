import 'dev_client_connection.dart';

class WsBroadcaster {
  late List<WsClientConnection> connections = [];

  void broadcast(String message, {Function(WsClientConnection)? skip}) {
    for (var connection in connections) {
      if (skip != null && skip(connection)) {
        continue;
      }

      connection.socket.add(message);
    }
  }
}
