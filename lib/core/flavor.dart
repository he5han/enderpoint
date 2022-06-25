import 'dart:io';

class Flavor {
  final String id;
  final int statusCode;
  final dynamic body;

  Flavor({this.statusCode = HttpStatus.ok, required this.id, required this.body});

  Flavor.fromJson(Map<String, dynamic> data)
      : id = data["id"],
        statusCode = data["statusCode"],
        body = data["body"];

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Flavor) {
      return other.id == id;
    }
    return super == other;
  }
}
