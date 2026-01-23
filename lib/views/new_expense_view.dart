import 'package:flutter/material.dart';

class NewExpenseView extends StatelessWidget {
  const NewExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Spesa')),
      body: const Center(child: Text('Form nuova spesa')),
    );
  }
}
