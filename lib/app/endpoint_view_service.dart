import 'package:rxdart/rxdart.dart';

import 'endpoint_collection.dart';

import '../core/flavor.dart';
import '../core/endpoint.dart';

class EndpointViewModel {
  List<Endpoint> endpoints;
  Endpoint? selectedEndpoint;

  EndpointViewModel({required this.endpoints, this.selectedEndpoint});
}

class EndpointViewService {
  final EndpointCollection _endpointCollection;

  late BehaviorSubject<EndpointViewModel> observable;
  late EndpointViewModel _viewModel;

  EndpointViewService(List<Endpoint> initialEndpoints) : _endpointCollection = EndpointCollection(initialEndpoints);

  setFlavor(Endpoint endpoint, Flavor flavor) {
    endpoint.flavor = flavor;
    _viewModel.endpoints = _endpointCollection.list;
    observable.add(_viewModel);
  }

  addEndpoint(Endpoint endpoint) {
    _endpointCollection.list.add(endpoint);
    _viewModel.endpoints = _endpointCollection.list;
    observable.add(_viewModel);
  }

  removeEndpoint(Endpoint endpoint) {
    _endpointCollection.list.remove(endpoint);
    _viewModel.endpoints = _endpointCollection.list;
    observable.add(_viewModel);
  }

  setSelectedEndpoint(Endpoint endpoint) {
    _viewModel.selectedEndpoint = endpoint;
    observable.add(_viewModel);
  }

  init() {
    _viewModel = EndpointViewModel(endpoints: []);
    observable = BehaviorSubject<EndpointViewModel>.seeded(_viewModel);
  }

  EndpointViewModel getCurrentSync() {
    return _viewModel;
  }
}
