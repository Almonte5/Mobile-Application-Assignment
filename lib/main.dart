import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mq_marketplace/screens/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MQMarketplaceApp());
}

class MQMarketplaceApp extends StatelessWidget {
  const MQMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQ Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C1A4B)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
