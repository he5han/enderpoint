import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../core/endpoint.dart';

class SelectedEndpointPresenter {
  late Endpoint? endpoint;
  late BehaviorSubject<Endpoint?> _observable;

  setEndpoint(Endpoint value) {
    _observable.add(endpoint = value);
  }

  clear() {
    _observable.add(endpoint = null);
  }

  init({Endpoint? initialEndpoint}) {
    _observable = BehaviorSubject<Endpoint?>.seeded(initialEndpoint);
  }

  Stream<Endpoint?> get stream => _observable.stream;
}
