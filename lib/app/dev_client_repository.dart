import 'dart:async';

import 'dev_client.dart';

class DevClientRepository {
  List<WsClient> list;
  final StreamController<DevClientRepository> _controller;

  DevClientRepository(this.list) : _controller = StreamController.broadcast();

  add(WsClient value) {
    list.add(value);
    _controller.sink.add(this);
  }

  remove(WsClient value, {bool disconnectBefore = false}) {
    if (disconnectBefore) {
      value.socket.close();
    }

    list.remove(value);
    _controller.sink.add(this);
  }

  findByAddress(String address) {
    return list.firstWhere((element) => element.address == address);
  }

  dispose() async {
    await _controller.close();
  }

  Stream<DevClientRepository> get stream => _controller.stream;
}
