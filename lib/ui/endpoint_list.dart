import 'package:flutter/material.dart';

import '../core/endpoint.dart';
import '../core/flavor.dart';

class EndpointList extends StatelessWidget {
  final List<Endpoint> endpoints;
  final Endpoint? selectedEndpoint;
  final Function(Flavor, Endpoint) onFlavorSelect;
  final Function(Endpoint) onSelect;
  final Function(Endpoint) onRemove;

  const EndpointList(
      {Key? key,
      required this.endpoints,
      required this.selectedEndpoint,
      required this.onFlavorSelect,
      required this.onSelect,
      required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: (endpoints)
          .map((endpoint) => EndpointCard(
                endpoint: endpoint,
                isSelected: endpoint == selectedEndpoint,
                onSelect: () => onSelect(endpoint),
                onFlavorSelect: (flavor) => onFlavorSelect(flavor, endpoint),
                onRemove: () => onRemove(endpoint),
              ))
          .toList(),
      shrinkWrap: false,
    );
  }
}

class EndpointCard extends StatelessWidget {
  final Endpoint endpoint;
  final bool isSelected;

  final Function(Flavor) onFlavorSelect;
  final Function() onRemove;
  final Function() onSelect;

  const EndpointCard(
      {Key? key,
      required this.endpoint,
      required this.onFlavorSelect,
      required this.onRemove,
      required this.onSelect,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => onSelect(),
            child: Row(
              children: [
                Expanded(child: Text(endpoint.url)),
                TextButton(onPressed: () => onRemove(), child: const Text("x"))
              ],
            ),
          ),
          Row(
              children: endpoint.flavors
                  .map((e) => TextButton(
                      onPressed: () => onFlavorSelect(e),
                      child: Text(
                        e.statusCode.toString(),
                        style: TextStyle(color: e == endpoint.flavor ? Colors.black : Colors.grey),
                      )))
                  .toList())
        ],
      ),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: isSelected ? Theme.of(context).primaryColor : Colors.transparent)),
    );
  }
}
