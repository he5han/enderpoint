import '../../core/endpoint.dart';

class SelectableEndpoint{
  final bool isSelected;
  final Endpoint endpoint;

  SelectableEndpoint(this.endpoint, this.isSelected);
}
