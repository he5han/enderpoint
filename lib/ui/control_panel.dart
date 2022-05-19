import 'dart:math';

import 'package:enderpoint/ui/endpoint_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/dev_client_presenter.dart';
import '../app/endpoint_presenter.dart';
import '../app/endpoint_server_presenter.dart';
import '../core/endpoint.dart';
import '../core/flavor.dart';
import 'endpoint_server_controls.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [EndpointServerControlsProviderAdapter(), EndpointCreator()],
        ),
        // const DevClintPresenterProviderAdapter(),
        const Expanded(child: EndpointListProviderAdapter()),
        const SelectedEndpoint()
      ],
    );
  }
}

class SelectedEndpoint extends StatelessWidget {
  const SelectedEndpoint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EndpointPresenter presenter = Provider.of<EndpointPresenter>(context);
    return StreamBuilder<EndpointViewModel>(
        stream: presenter.observable,
        builder: (context, snapshot) => snapshot.data?.selectedEndpoint != null &&
                snapshot.data!.endpoints.contains(snapshot.data!.selectedEndpoint)
            ? EndpointCard(
                endpoint: snapshot.data!.selectedEndpoint!,
                onFlavorSelect: (flavor) => presenter.setFlavor(snapshot.data!.selectedEndpoint!, flavor),
                onRemove: () => null,
                onSelect: () => null,
                isSelected: false)
            : const SizedBox());
  }
}

class EndpointCreator extends StatelessWidget {
  const EndpointCreator({Key? key}) : super(key: key);

  Endpoint generateEndpoint() {
    int rNum = Random().nextInt(100);
    return Endpoint(
        rNum,
        [
          Flavor(identifier: 0x00, body: {"msg": "hello world"}, statusCode: 200),
          Flavor(identifier: 0x02, body: {"msg": "Error"}, statusCode: 500),
        ],
        "/test-$rNum");
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Provider.of<EndpointPresenter>(context, listen: false).addEndpoint(generateEndpoint()),
        child: const Text("Create Endpoint"));
  }
}

class DevClintPresenterProviderAdapter extends StatelessWidget {
  const DevClintPresenterProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DevClintPresenter presenter = Provider.of<DevClintPresenter>(context);
    return StreamBuilder<DevClientViewModel>(
        stream: presenter.observable,
        builder: (context, snapshot) =>
            Row(children: (snapshot.data?.clients ?? []).map((e) => Text(e.address.toString())).toList()));
  }
}

class EndpointListProviderAdapter extends StatelessWidget {
  const EndpointListProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EndpointPresenter presenter = Provider.of<EndpointPresenter>(context);
    return StreamBuilder<EndpointViewModel>(
        stream: presenter.observable,
        builder: (context, snapshot) => EndpointList(
            endpoints: snapshot.data?.endpoints ?? [],
            selectedEndpoint: snapshot.data?.selectedEndpoint,
            onFlavorSelect: (flavor, endpoint) => presenter.setFlavor(endpoint, flavor),
            onSelect: (endpoint) => presenter.setSelectedEndpoint(endpoint),
            onRemove: (endpoint) => presenter.removeEndpoint(endpoint)));
  }
}

class EndpointServerControlsProviderAdapter extends StatelessWidget {
  const EndpointServerControlsProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EndpointServerPresenter presenter = Provider.of<EndpointServerPresenter>(context);
    return StreamBuilder<EndpointServerViewModel>(
      stream: presenter.observable,
      builder: (context, snapshot) => EndpointServerControls(
          isAbleToStart: snapshot.data != null && snapshot.data!.state == ServerState.closed,
          onStart: presenter.start,
          onStop: presenter.stop),
    );
  }
}
