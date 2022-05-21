import 'dart:io';

class Flavor {
  final int identifier;
  final int statusCode;
  final dynamic body;

  Flavor(
      {this.statusCode = HttpStatus.ok,
      required this.identifier,
      required this.body});


  @override
  int get hashCode => identifier;

  @override
  bool operator ==(Object other) {
    if(other is Flavor){
      return other.identifier == identifier;
    }
    return super == other;
  }
}
