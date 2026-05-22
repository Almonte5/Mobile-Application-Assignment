import 'package:flutter/material.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/services/location_service.dart';
import 'package:mq_marketplace/widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    ListingService? listingService,
    LocationService? locationService,
    AuthService? authService,
  })  : _listingService = listingService,
        _locationService = locationService,
        _authService = authService;

  final ListingService? _listingService;
  final LocationService? _locationService;
  final AuthService? _authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ListingService _listingService;
  late final LocationService _locationService;
  late final AuthService _authService;

  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _listingService = widget._listingService ?? ListingService();
    _locationService = widget._locationService ?? LocationService();
    _authService = widget._authService ?? AuthService();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final geoPoint = await _locationService.getCurrentLocation();
    if (geoPoint != null && mounted) {
      setState(() {
        _userLat = geoPoint.latitude;
        _userLng = geoPoint.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQ Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Listing>>(
        stream: _listingService.getListings(),
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
              child: Text('No listings yet. Be the first to sell something!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListingCard(
                  listing: listings[index],
                  userLat: _userLat,
                  userLng: _userLng,
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
