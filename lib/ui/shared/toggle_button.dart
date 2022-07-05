import 'package:flutter/material.dart';

class ToggleSwitchOption {
  String value;
  bool isSelected;

  ToggleSwitchOption({
    required this.value,
    required this.isSelected,
  });
}

class ToggleSwitch extends StatelessWidget {
  final Color primaryColor;
  final Color highlightColor;
  final List<ToggleSwitchOption> options;
  final Function(ToggleSwitchOption)? onSelect;

  const ToggleSwitch({
    Key? key,
    this.onSelect,
    required this.options,
    required this.primaryColor,
    required this.highlightColor,
  }) : super(key: key);

  Widget buildToggleItem(BuildContext context, ToggleSwitchOption option) {
    return GestureDetector(
      onTap: () => onSelect?.call(option),
      child: Container(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: option.isSelected ? primaryColor : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        height: double.infinity,
        alignment: Alignment.center,
        child: Text(
          option.value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: option.isSelected ? highlightColor : primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(width: 2, color: primaryColor),
        ),
      ),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => buildToggleItem(context, option),
              )
              .toList()),
    );
  }
}
