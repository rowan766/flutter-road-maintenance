import 'package:flutter/material.dart';

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('道路巡查')),
      body: const Center(child: Text('巡查页面')),
    );
  }
}
