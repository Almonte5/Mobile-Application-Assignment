import 'package:flutter/material.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove listing?'),
        content: const Text(
          'This will mark your listing as sold and remove it from the feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // close dialog
              await ListingService().deleteListing(listing.id);
              if (context.mounted) Navigator.of(context).pop(); // back to feed
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner = AuthService().currentUser?.uid == listing.sellerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewListingScreen(listing: listing),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRow(theme),
                  const SizedBox(height: 8),
                  Text(
                    listing.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryChip(theme),
                  const Divider(height: 32),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  _buildSellerSection(theme),
                  const SizedBox(height: 24),
                  if (isOwner)
                    _buildOwnerActions(context)
                  else
                    _buildContactButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty) {
      return Image.network(
        listing.imageUrl!,
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 280,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported,
        size: 64,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildPriceRow(ThemeData theme) {
    return Text(
      '\$${listing.price.toStringAsFixed(2)}',
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Chip(
      label: Text(listing.category.displayName),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
    );
  }

  Widget _buildSellerSection(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.person_outline),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listed by',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              listing.sellerName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Mark as Sold'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _contactSeller(context),
        icon: const Icon(Icons.email_outlined),
        label: const Text('Contact Seller'),
      ),
    );
  }

  void _contactSeller(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contact ${listing.sellerName} at ${listing.sellerEmail}',
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }
}