import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mq_marketplace/models/category.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/models/listing_status.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/image_upload_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';

class NewListingScreen extends StatefulWidget {
  const NewListingScreen({
    super.key,
    this.listing,
    AuthService? authService,
    ListingService? listingService,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _listingService = listingService,
        _firestore = firestore;

  final Listing? listing;
  final AuthService? _authService;
  final ListingService? _listingService;
  final FirebaseFirestore? _firestore;

  bool get isEditing => listing != null;

  @override
  State<NewListingScreen> createState() => _NewListingScreenState();
}

class _NewListingScreenState extends State<NewListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  late Category _selectedCategory;
  XFile? _pickedImage;
  bool _isLoading = false;

  late final AuthService _authService;
  late final ListingService _listingService;
  late final FirebaseFirestore _firestore;
  final _imagePicker = ImagePicker();
  final _imageUploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? AuthService();
    _listingService = widget._listingService ?? ListingService();
    _firestore = widget._firestore ?? FirebaseFirestore.instance;

    if (widget.isEditing) {
      final l = widget.listing!;
      _titleController.text = l.title;
      _descriptionController.text = l.description;
      _priceController.text = l.price.toString();
      _selectedCategory = l.category;
      if (l.location != null) {
        _latController.text = l.location!.latitude.toString();
        _lngController.text = l.location!.longitude.toString();
      }
    } else {
      _selectedCategory = Category.textbooks;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  GeoPoint? _buildLocation() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) return null;
    return GeoPoint(lat, lng);
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Not logged in');

      String? imageUrl = widget.listing?.imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _imageUploadService.uploadImage(_pickedImage!);
      }

      final location = _buildLocation();
      final now = DateTime.now();

      if (widget.isEditing) {
        final updated = Listing(
          id: widget.listing!.id,
          sellerId: widget.listing!.sellerId,
          sellerName: widget.listing!.sellerName,
          sellerEmail: widget.listing!.sellerEmail,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          imageUrl: imageUrl,
          location: location ?? widget.listing!.location,
          status: widget.listing!.status,
          createdAt: widget.listing!.createdAt,
          updatedAt: now,
        );
        await _listingService.updateListing(updated);
      } else {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final sellerName =
            userDoc.data()?['displayName'] as String? ?? 'Unknown';
        final sellerEmail = userDoc.data()?['email'] as String? ?? '';

        final listing = Listing(
          id: '',
          sellerId: user.uid,
          sellerName: sellerName,
          sellerEmail: sellerEmail,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          imageUrl: imageUrl,
          location: location,
          status: ListingStatus.available,
          createdAt: now,
          updatedAt: now,
        );
        await _listingService.createListing(listing);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Listing' : 'New Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _pickedImage!.path,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.listing?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.listing!.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Photo (optional)',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 80,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  maxLength: 1000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (AUD)',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: Category.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Location (optional)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude (S)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // optional
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null ||
                              parsed < -90 ||
                              parsed > 90) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude (E)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // optional
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null ||
                              parsed < -180 ||
                              parsed > 180) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Post Listing',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}