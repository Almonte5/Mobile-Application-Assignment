import 'package:flutter/material.dart';
import 'package:mq_marketplace/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQ Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to MQ Marketplace!'),
      ),
    );
  }
}