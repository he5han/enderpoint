import 'package:rxdart/rxdart.dart';

import 'endpoint_server.dart';

enum ServerState { closed, idle }

class EndpointServerViewModel {
  ServerState state;

  EndpointServerViewModel({required this.state});
}

class EndpointServerPresenter {
  final EndpointServer server;

  late EndpointServerViewModel _viewModel;
  late BehaviorSubject<EndpointServerViewModel> observable;

  EndpointServerPresenter(this.server);

  start() {
    server.listen(onDone: stop);
    _viewModel.state = ServerState.idle;
    observable.add(_viewModel);
  }

  stop() async {
    await server.cancel();
    _viewModel.state = ServerState.closed;
    observable.add(_viewModel);
  }

  init() {
    _viewModel = EndpointServerViewModel(state: ServerState.closed);
    observable = BehaviorSubject<EndpointServerViewModel>.seeded(_viewModel);
  }
}
