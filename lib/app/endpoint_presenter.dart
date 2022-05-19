import 'package:rxdart/rxdart.dart';

import 'endpoint_repository.dart';

import '../core/flavor.dart';
import '../core/endpoint.dart';

class EndpointViewModel {
  List<Endpoint> endpoints;
  Endpoint? selectedEndpoint;

  EndpointViewModel({required this.endpoints, this.selectedEndpoint});
}

class EndpointPresenter {
  final EndpointRepository endpointCollection;

  late BehaviorSubject<EndpointViewModel> observable;
  late EndpointViewModel _viewModel;

  EndpointPresenter(this.endpointCollection);

  setFlavor(Endpoint endpoint, Flavor flavor) {
    endpoint.flavor = flavor;
    _viewModel.endpoints = endpointCollection.list;
    observable.add(_viewModel);
  }

  addEndpoint(Endpoint endpoint) {
    endpointCollection.list.add(endpoint);
    _viewModel.endpoints = endpointCollection.list;
    observable.add(_viewModel);
  }

  removeEndpoint(Endpoint endpoint) {
    endpointCollection.list.remove(endpoint);
    _viewModel.endpoints = endpointCollection.list;
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

  EndpointViewModel get model => _viewModel;
}
