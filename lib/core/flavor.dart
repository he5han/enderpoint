import 'dart:io';

class Flavor {
  String id;
  int statusCode;
  dynamic body;

  Map<String, dynamic>? headers = const {};

  Flavor({this.statusCode = HttpStatus.ok, required this.id, required this.body, this.headers});

  Flavor.fromJson(Map<String, dynamic> data)
      : id = data["id"],
        statusCode = data["statusCode"],
        headers = data["headers"],
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

extension ToJson on Flavor {
  toJson() {
    return {"id": id, "statusCode": statusCode, "body": body, "headers": headers};
  }
}
