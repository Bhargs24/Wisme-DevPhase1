import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const AppSearchField({
    Key? key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
