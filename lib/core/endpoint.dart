import 'flavor.dart';

class Endpoint {
  final int identifier;
  final List<Flavor> flavors;
  final String url;

  Flavor flavor;

  Endpoint(this.identifier, this.flavors, this.url, {Flavor? flavor})
      : flavor = flavor ?? flavors.first;

  // URL is supposed to be unique
  @override
  bool operator ==(Object other) {
    if (other is Endpoint) {
      return other.url == url || super == other;
    }
    return super == other;
  }

  @override
  int get hashCode => identifier;
}
