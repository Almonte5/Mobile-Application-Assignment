import 'package:flutter/material.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/widgets/listing_card.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({
    super.key,
    ListingService? listingService,
    AuthService? authService,
  })  : _listingService = listingService,
        _authService = authService;

  final ListingService? _listingService;
  final AuthService? _authService;

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late final ListingService _listingService;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _listingService = widget._listingService ?? ListingService();
    _authService = widget._authService ?? AuthService();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Listings')),
        body: const Center(child: Text('Not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: StreamBuilder<List<Listing>>(
        stream: _listingService.getMyListings(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          }

          final listings = snapshot.data ?? [];

          if (listings.isEmpty) {
            return const Center(
              child: Text("You haven't listed anything yet."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  children: [
                    ListingCard(listing: listing),
                    if (listing.status.firestoreValue == 'sold')
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'SOLD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
