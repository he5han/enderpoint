import '../core/endpoint.dart';

class EndpointRepository {
  final List<Endpoint> list;

  EndpointRepository(this.list);

  findByUrl(String url) {
    return list.firstWhere((element) => element.url == url);
  }
}