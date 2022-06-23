import 'dart:async';

import '../core/endpoint.dart';

class EndpointRepository {
  final StreamController<EndpointRepository> _controller;
  final List<Endpoint> list;

  EndpointRepository(this.list) : _controller = StreamController.broadcast();

  void _notify() {
    _controller.sink.add(this);
  }

  void add(Endpoint value) {
    list.add(value);
    _notify();
  }

  void remove(Endpoint value) {
    list.remove(value);
    _notify();
  }

  void update(Endpoint value, Endpoint nextValue) {
    value = nextValue;
    _notify();
  }

  Endpoint? findByUrl(String url) {
    return list.firstWhere((element) => element.url == url);
  }

  Stream<EndpointRepository> get stream => _controller.stream;
}