import 'dev_client.dart';

class DevClientRepository {
  Function(DevClientRepository)? onChange;
  List<DevClient> list;

  DevClientRepository(this.list, { this.onChange});

  add(DevClient value) {
    list.add(value);
    onChange ?? (this);
  }

  remove(DevClient value) {
    list.remove(value);
    onChange ?? (this);
  }

  findByAddress(String address) {
    return list.firstWhere((element) => element.address == address);
  }
}
