import 'dart:async';

import '../core/endpoint.dart';

class EndpointRepository {
  final StreamController<List<Endpoint>> _controller;
  final Map<String, Endpoint> map;

  EndpointRepository(List<Endpoint> endpoints)
      : _controller = StreamController.broadcast(),
        map = Map.fromEntries(endpoints.map((endpoint) => MapEntry(endpoint.id, endpoint)));

  void _notify() {
    _controller.sink.add(list);
  }

  void add(Endpoint value) {
    map.addEntries([MapEntry(value.id, value)]);
    _notify();
  }

  void remove(String id) {
    map.remove(id);
    _notify();
  }

  void update(String id, Endpoint nextValue) {
    map.update(id, (_) => nextValue);
    _notify();
  }

  Endpoint? findByUrl(String url) {
    return list.firstWhere((element) => element.url == url);
  }

  Endpoint? findById(String id) {
    return map[id];
  }

  Stream<List<Endpoint>> get stream => _controller.stream;

  List<Endpoint> get list => map.values.toList();
}
