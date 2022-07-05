import 'package:flutter/material.dart';

import '../icons.dart';

enum ConnectionButtonState {
  connected,
  disconnected,
}

class ConnectionButton extends StatelessWidget {
  final Color fgConnected;
  final Color bgConnected;
  final Color fgDisconnected;
  final Color bgDisconnected;
  final ConnectionButtonState state;

  const ConnectionButton({
    Key? key,
    required this.state,
    required this.fgConnected,
    required this.bgConnected,
    required this.fgDisconnected,
    required this.bgDisconnected,
  }) : super(key: key);

  Widget buildIcon(BuildContext context) {
    switch (state) {
      case ConnectionButtonState.connected:
        return Icon(FeatherIcons.wifi, size: 20, color: fgConnected);
      case ConnectionButtonState.disconnected:
        return Icon(FeatherIcons.wifiOff, size: 20, color: fgDisconnected);
    }
  }

  Color getBackgroundColor(BuildContext context) {
    switch (state) {
      case ConnectionButtonState.connected:
        return bgConnected;
      case ConnectionButtonState.disconnected:
        return bgDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: getBackgroundColor(context),
      ),
      child: buildIcon(context),
    );
  }
}
