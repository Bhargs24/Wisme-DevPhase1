import 'package:flutter/material.dart';

class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ComponentShowcaseScreen')),
      body: const Center(
        child: Text('ComponentShowcaseScreen - Coming Soon'),
      ),
    );
  }
}
