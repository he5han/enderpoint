import 'flavor.dart';

class Endpoint {
  final String id;
  final List<Flavor> flavors;
  final String url;

  Flavor? flavor;

  Endpoint(this.id, this.flavors, this.url, {Flavor? initialFlavor}) : flavor = initialFlavor;

  Endpoint.fromJson(Map<String, dynamic> data, {Flavor? initialFlavor})
      : id = data["id"],
        url = data["url"],
        flavor = initialFlavor,
        flavors = data["flavors"].map<Flavor>((flavor) => Flavor.fromJson(flavor)).toList();

  @override
  bool operator ==(Object other) {
    if (other is Endpoint) {
      return other.id == id || super == other;
    }
    return super == other;
  }

  @override
  int get hashCode => id.hashCode;
}

extension ToJson on Endpoint {
  toJson() {
    return {
      "id": id,
      "url": url,
      "flavors": flavors.map((flavor) => flavor.toJson()).toList(),
      // "flavor": flavor?.toJson()
    };
  }
}
