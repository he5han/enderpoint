import '../core/endpoint.dart';

class EndpointCollection {
  final List<Endpoint> list;

  EndpointCollection(this.list);

  findByUrl(String url) {
    return list.firstWhere((element) => element.url == url);
  }
}