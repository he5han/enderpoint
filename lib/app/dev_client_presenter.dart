import 'package:enderpoint/app/dev_client.dart';
import 'package:enderpoint/app/dev_client_repository.dart';
import 'package:rxdart/rxdart.dart';

class DevClientViewModel {
  List<DevClient> clients;

  DevClientViewModel({this.clients = const []});
}

class DevClintPresenter {
  late DevClientViewModel _viewModel;
  late BehaviorSubject<DevClientViewModel> observable;

  init(DevClientRepository repository) {
    _viewModel = DevClientViewModel();
    observable = BehaviorSubject<DevClientViewModel>.seeded(_viewModel);
    // repository.onChange = (d) => observable.add(DevClientViewModel(clients: d.list));
  }
}
