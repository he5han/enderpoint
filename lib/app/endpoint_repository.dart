import 'dart:async';

import '../core/endpoint.dart';

class EndpointRepository {
  final StreamController<EndpointRepository> _controller;
  final List<Endpoint> list;

  EndpointRepository(this.list) : _controller = StreamController.broadcast();

  add(Endpoint value) {
    list.add(value);
    _controller.sink.add(this);
  }

  remove(Endpoint value) {
    list.remove(value);
    _controller.sink.add(this);
  }

  update(Endpoint value, Endpoint nextValue) {
    value = nextValue;
    _controller.sink.add(this);
  }

  findByUrl(String url) {
    return list.firstWhere((element) => element.url == url);
  }

  Stream<EndpointRepository> get stream => _controller.stream;
}
