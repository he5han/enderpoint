import 'dart:io';
import 'dart:math';

import 'package:enderpoint/app.dart';
import 'package:enderpoint/ui/endpoint_list.dart';
import 'package:enderpoint/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../app/dev_client_repository.dart';
import '../app/endpoint_bootstraper.dart';
import '../app/endpoint_server_presenter.dart';

import '../core/endpoint.dart';
import '../core/flavor.dart';

import 'endpoint_server_controls.dart';
import 'models/selectable_endpoint.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Column(
      children: [
        const IpContainer(),
        Row(
          children: const [EndpointServerControlsProviderAdapter(), EndpointCreator()],
        ),
        const DevClintPresenterProviderAdapter(),
        Container(height: 10, width: 10, color: color),
        TextButton(
            onPressed: () {
              ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
            child: Text("Set light theme", style: TextStyle(color: color))),
        const Expanded(child: EndpointListProviderAdapter()),
        const SelectedEndpoint()
      ],
    );
  }
}

class IpContainer extends StatelessWidget {
  const IpContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NetworkInterface>>(
        future: NetworkInterface.list(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return Text(snapshot.data!.first.addresses.toString());
              } else {
                return const Text("N/A");
              }
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
          }

          return const Text("Waiting...");
        });
  }
}

class SelectedEndpoint extends StatelessWidget {
  const SelectedEndpoint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    App app = Provider.of<App>(context);

    return StreamBuilder<Endpoint?>(
        stream: app.selectedEndpointObserver,
        builder: (context, snapshot) => snapshot.data != null
            ? EndpointCard(
                endpoint: snapshot.data!,
                onFlavorSelect: (flavor) =>
                    app.endpointRepository.update(snapshot.data!.id, snapshot.data!..flavor = flavor),
                onRemove: () => app.endpointRepository.remove(snapshot.data!.id),
                onSelect: () => null,
                isSelected: false)
            : const SizedBox());
  }
}

class EndpointCreator extends StatelessWidget {
  const EndpointCreator({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () =>
            Provider.of<App>(context, listen: false).endpointRepository.add(EndpointBootstraper.bootstrap().toJson()),
        child: const Text("Create Endpoint"));
  }
}

class DevClintPresenterProviderAdapter extends StatelessWidget {
  const DevClintPresenterProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WsClientConnectionRepository>(
        stream: Provider.of<App>(context).wsClientConnectionRepository.stream,
        builder: (context, snapshot) => Row(
            children: (snapshot.data?.list ?? [])
                .map((wsClient) => TextButton(
                    child: Text(wsClient.address.toString()),
                    onPressed: () async => await snapshot.data?.remove(wsClient, disconnectBefore: true)))
                .toList()));
  }
}

class EndpointListProviderAdapter extends StatelessWidget {
  const EndpointListProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    App app = Provider.of<App>(context);

    return StreamBuilder<List<SelectableEndpoint>>(
        stream: app.selectableEndpointListObserver,
        builder: (context, snapshot) => EndpointList(
            items: snapshot.data ?? [],
            onFlavorSelect: (flavor, endpoint) => app.endpointRepository.update(endpoint.id, endpoint..flavor = flavor),
            onSelect: (endpoint) => app.selectedEndpointPresenter.setEndpoint(endpoint),
            onRemove: (endpoint) => app.endpointRepository.remove(endpoint.id)));
  }
}

class EndpointServerControlsProviderAdapter extends StatelessWidget {
  const EndpointServerControlsProviderAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EndpointServerPresenter presenter = Provider.of<App>(context).endpointServerPresenter;

    return StreamBuilder<EndpointServerViewModel>(
      stream: presenter.observable,
      builder: (context, snapshot) => EndpointServerControls(
          isAbleToStart: snapshot.data != null && snapshot.data!.state == ServerState.closed,
          onStart: presenter.start,
          onStop: presenter.stop),
    );
  }
}
