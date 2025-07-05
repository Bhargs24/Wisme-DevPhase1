import 'package:flutter/material.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShowcaseScreen')),
      body: const Center(
        child: Text('ShowcaseScreen - Coming Soon'),
      ),
    );
  }
}
