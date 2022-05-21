import 'dart:math';

import 'package:enderpoint/app/endpoint_repository.dart';
import 'package:enderpoint/ui/endpoint_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../app/dev_client_repository.dart';
import '../app/endpoint_server_presenter.dart';
import '../app/selected_endpoint_presenter.dart';
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
        const DevClintPresenterProviderAdapter(),
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
    SelectedEndpointPresenter presenter = Provider.of<SelectedEndpointPresenter>(context);
    EndpointRepository repository = Provider.of<EndpointRepository>(context);

    return StreamBuilder<Endpoint?>(
        stream: Rx.combineLatest2<Endpoint?, EndpointRepository, Endpoint?>(
            presenter.stream, repository.stream, (point, repo) => repo.list.contains(point) ? point : null),
        builder: (context, snapshot) => snapshot.data != null
            ? EndpointCard(
                endpoint: snapshot.data!,
                onFlavorSelect: (flavor) => repository.update(snapshot.data!, snapshot.data!..flavor = flavor),
                onRemove: () => repository.remove(snapshot.data!),
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
        onPressed: () => Provider.of<EndpointRepository>(context, listen: false).add(generateEndpoint()),
        child: const Text("Create Endpoint"));
  }
}

class DevClintPresenterProviderAdapter extends StatelessWidget {
  const DevClintPresenterProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DevClientRepository repository = Provider.of<DevClientRepository>(context);

    return StreamBuilder<DevClientRepository>(
        stream: repository.stream,
        builder: (context, snapshot) => Row(
            children: (snapshot.data?.list ?? [])
                .map((wsClient) => TextButton(
                    child: Text(wsClient.address.toString()),
                    onPressed: () async => await snapshot.data?.remove(wsClient, disconnectBefore: true)))
                .toList()));
  }
}

class SelectableListViewModel {
  final Endpoint? selected;
  final List<Endpoint> list;

  SelectableListViewModel({this.selected, required this.list});
}

class EndpointListProviderAdapter extends StatelessWidget {
  const EndpointListProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectedEndpointPresenter presenter = Provider.of<SelectedEndpointPresenter>(context);
    EndpointRepository repository = Provider.of<EndpointRepository>(context);

    return StreamBuilder<SelectableListViewModel>(
        stream: Rx.combineLatest2<Endpoint?, EndpointRepository, SelectableListViewModel>(
            presenter.stream, repository.stream, (a, b) => SelectableListViewModel(selected: a, list: b.list)),
        builder: (context, snapshot) => EndpointList(
            endpoints: snapshot.data?.list ?? [],
            selectedEndpoint: snapshot.data?.selected,
            onFlavorSelect: (flavor, endpoint) => repository.update(endpoint, endpoint..flavor = flavor),
            onSelect: (endpoint) => presenter.setEndpoint(endpoint),
            onRemove: (endpoint) => repository.remove(endpoint)));
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
