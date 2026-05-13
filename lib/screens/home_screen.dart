import 'package:flutter/material.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/widgets/listing_card.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingService = ListingService();
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
      body: StreamBuilder<List<Listing>>(
        stream: listingService.getListings(),
        builder: (context, snapshot) {
          // Still waiting for first data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Stream emitted an error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          }

          final listings = snapshot.data ?? [];

          // Empty state
          if (listings.isEmpty) {
            return const Center(
              child: Text('No listings yet. Be the first to sell something!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListingCard(listing: listings[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewListingScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
