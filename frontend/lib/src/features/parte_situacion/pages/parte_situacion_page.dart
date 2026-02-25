import 'package:flutter/material.dart';
import '../../../core/common_widgets/custom_app_bar.dart';

class ParteSituacionPage extends StatelessWidget {
  const ParteSituacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
      ),
      body: const Center(
        child: Text(
          'PARTE DE SITUACIÓN',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
