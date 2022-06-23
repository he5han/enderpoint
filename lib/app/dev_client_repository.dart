import 'dart:async';

import 'dev_client_connection.dart';

class WsClientConnectionRepository {
  List<WsClientConnection> list;
  final StreamController<WsClientConnectionRepository> _controller;

  WsClientConnectionRepository(this.list) : _controller = StreamController.broadcast();

  _notify() {
    _controller.sink.add(this);
  }

  add(WsClientConnection value) {
    list.add(value);
    _notify();
  }

  remove(WsClientConnection value, {bool disconnectBefore = false}) {
    if (disconnectBefore) {
      value.socket.close();
    }

    list.remove(value);
    _notify();
  }

  findByAddress(String address) {
    return list.firstWhere((element) => element.address == address);
  }

  dispose() async {
    await _controller.close();
  }

  Stream<WsClientConnectionRepository> get stream => _controller.stream;
}
