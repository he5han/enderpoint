import 'package:flutter/material.dart';

import 'shared/toggle_button.dart';

class EndpointServerControls extends StatelessWidget {
  final bool isAbleToStart;
  final Function() onStart;
  final Function() onStop;

  const EndpointServerControls({Key? key, required this.isAbleToStart, required this.onStart, required this.onStop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAbleToStart,
      child: TextButton(onPressed: onStart, child: const Text("Start server")),
      replacement: TextButton(onPressed: onStop, child: const Text("Destroy server")),
    );
  }
}
