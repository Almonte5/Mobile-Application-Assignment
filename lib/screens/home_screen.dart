import 'package:flutter/material.dart';
import 'package:mq_marketplace/models/category.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/services/location_service.dart';
import 'package:mq_marketplace/widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    ListingService? listingService,
    LocationService? locationService,
  })  : _listingService = listingService,
        _locationService = locationService;

  final ListingService? _listingService;
  final LocationService? _locationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ListingService _listingService;
  late final LocationService _locationService;

  double? _userLat;
  double? _userLng;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _listingService = widget._listingService ?? ListingService();
    _locationService = widget._locationService ?? LocationService();
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

  List<Listing> _applyFilter(List<Listing> listings) {
    if (_selectedCategory == null) return listings;
    return listings.where((l) => l.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQ Marketplace'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<Listing>>(
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

                final listings = _applyFilter(snapshot.data ?? []);

                if (listings.isEmpty) {
                  return const Center(
                    child: Text(
                        'No listings yet. Be the first to sell something!'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategory == null,
            onSelected: (_) => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...Category.values.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c.displayName),
                selected: _selectedCategory == c,
                onSelected: (_) => setState(() => _selectedCategory = c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
