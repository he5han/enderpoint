import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:enderpoint/app.dart';
import 'package:enderpoint/ui/endpoint_list.dart';
import 'package:enderpoint/ui/icons.dart';
import 'package:enderpoint/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../app/dev_client_repository.dart';
import '../app/endpoint_bootstraper.dart';
import '../app/endpoint_server_presenter.dart';

import '../core/endpoint.dart';
import '../core/flavor.dart';

import 'endpoint_server_controls.dart';
import 'models/selectable_endpoint.dart';
import 'shared/connection_button.dart';
import 'shared/toggle_button.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: IpContainer(),
        // ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Header(),
        ),
        ServerControllerCard(
          background: Theme.of(context).colorScheme.primary,
          foreground: Colors.white,
        ),
        SizedBox(height: 15),
        ControlCard(
          title: "Endpoint Controls",
          subtitle: "Endpoint Controls",
          icon: FeatherIcons.target,
        ),
        SizedBox(height: 15),
        ControlCard(
          title: "Activity Monitor",
          subtitle: "Traffic log & Activities",
          icon: FeatherIcons.activity,
        ),
        // Row(
        //   children: const [EndpointServerControlsProviderAdapter(), EndpointCreator()],
        // ),
        // const DevClintPresenterProviderAdapter(),
        // Container(height: 10, width: 10, color: color),
        // TextButton(
        //     onPressed: () {
        //       ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        //       themeProvider.toggleTheme();
        //     },
        //     child: Text("Set light theme", style: TextStyle(color: color))),
        // const Expanded(child: EndpointListProviderAdapter()),
        // const SelectedEndpoint()
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        const Center(
          child: Text(
            "Controls",
            style: TextStyle(
              letterSpacing: 1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            // alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: const Color(0xff01334F).withOpacity(0.1),
              shape: const CircleBorder(),
            ),
            child: const Icon(
              FeatherIcons.moon,
              size: 20,
            ),
          ),
        )
      ],
    );
  }
}

class ServerControllerCard extends StatelessWidget {
  final Color foreground;
  final Color background;

  final Connectivity _connectivity = Connectivity();

  ServerControllerCard({
    Key? key,
    required this.foreground,
    required this.background,
  }) : super(key: key);

  Widget renderAddress(BuildContext context, String address, String port) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(
        width: double.infinity,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              alignment: Alignment.topLeft,
              child: RichText(
                maxLines: 1,
                textAlign: TextAlign.start,
                textScaleFactor: 1,
                text: TextSpan(
                  children: [
                    TextSpan(text: address),
                    TextSpan(
                      text: port,
                      style: TextStyle(color: foreground.withOpacity(0.5)),
                    ),
                  ],
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    leadingDistribution: TextLeadingDistribution.even,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 5),
          //   child: Icon(
          //     FeatherIcons.copy,
          //     size: 15,
          //     color: foreground.withOpacity(0.4),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget renderConnectivityControls(BuildContext context) {
    EndpointServerPresenter _endpointServerPresenter = Provider.of<App>(context).endpointServerPresenter;
    ConnectionButtonState _connectivityResultToConnectionButtonState(ConnectivityResult result) {
      if (result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        return ConnectionButtonState.connected;
      }
      return ConnectionButtonState.disconnected;
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: StreamBuilder<ConnectivityResult>(
            stream: _connectivity.onConnectivityChanged,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ConnectionButton(
                  fgConnected: background,
                  bgConnected: const Color(0xff00FFF0),
                  fgDisconnected: const Color(0xff00FFF0),
                  bgDisconnected: foreground.withOpacity(0.2),
                  // state: ConnectionButtonState.disconnected,
                  state: _connectivityResultToConnectionButtonState(snapshot.data!),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5, left: 10),
          child: StreamBuilder<EndpointServerViewModel>(
            stream: _endpointServerPresenter.observable,
            builder: (context, snapshot) {
              return ToggleSwitch(
                highlightColor: background,
                primaryColor: foreground,
                onSelect: (option) =>
                    option.value == "ON" ? _endpointServerPresenter.start() : _endpointServerPresenter.stop(),
                options: [
                  ToggleSwitchOption(value: "OFF", isSelected: snapshot.data?.state == ServerState.closed),
                  ToggleSwitchOption(value: "ON", isSelected: snapshot.data?.state == ServerState.idle),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  String? _findV4Address(List<NetworkInterface>? interfaces) {
    InternetAddress? _address;
    if (interfaces != null) {
      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            _address = address;
          }
        }
      }
    }
    return _address?.address;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      constraints: const BoxConstraints.tightFor(width: double.infinity),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Local IP Address (IPv4)",
            style: TextStyle(color: foreground, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FutureBuilder<List<NetworkInterface>>(
                future: NetworkInterface.list(),
                builder: (context, snapshot) {
                  return renderAddress(
                    context,
                    "${_findV4Address(snapshot.data ?? []) ?? '~'}:",
                    "8080",
                  );
                }),
          ),
          Text(
            "Server Connectivity",
            style: TextStyle(color: foreground, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: renderConnectivityControls(context),
          ),
          // const SizedBox(
          //   height: 15,
          // ),
          // const Text(
          //   "Server Type",
          //   style: TextStyle(color: Colors.white, fontSize: 16),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 5),
          //   child: ToggleSwitch(
          //     options: [
          //       ToggleSwitchOption(value: "PROXY", isSelected: true),
          //       ToggleSwitchOption(value: "STD", isSelected: false)
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ControlCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ControlCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xff01334F).withOpacity(0.08),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Expanded(
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff01334F),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xff01334F).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            FeatherIcons.arrowRight,
            size: 25,
            color: Color(0xff01334F),
          )
        ],
      ),
    );
  }
}

@deprecated
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Local IP Address (IPv4)",
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                    AspectRatio(
                      aspectRatio: 8,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.contain,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: snapshot.data!.first.addresses.first.address,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const TextSpan(text: ":"),
                            const TextSpan(text: "8080", style: TextStyle(color: Colors.indigo)),
                          ], style: DefaultTextStyle.of(context).style),
                        ),
                      ),
                    )
                  ],
                );
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
