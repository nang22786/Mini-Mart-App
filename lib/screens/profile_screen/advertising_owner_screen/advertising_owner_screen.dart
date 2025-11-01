import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_mart/bloc/advertising/advertising_bloc.dart';
import 'package:mini_mart/bloc/advertising/advertising_event.dart';
import 'package:mini_mart/bloc/advertising/advertising_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/advertising/advertising_model.dart';
import 'package:mini_mart/styles/fonts.dart';

class AdvertisingOwnerScreen extends StatefulWidget {
  const AdvertisingOwnerScreen({super.key});

  @override
  State<AdvertisingOwnerScreen> createState() => _AdvertisingOwnerScreenState();
}

class _AdvertisingOwnerScreenState extends State<AdvertisingOwnerScreen> {
  final ImagePicker _picker = ImagePicker();

  // Define custom colors to perfectly match the appearance
  static const Color _darkBackgroundColor = Color(0xFF1C1C1E);
  static const Color _lightGreenActive = Color(0xFF66CC66);
  static const Color _darkGreyInactive = Color(0xFF555555);
  static const Color _thumbColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Load advertising data
    context.read<AdvertisingBloc>().add(const LoadAdvertising());
  }

  // Add new advertising
  Future<void> _addAdvertising() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null && mounted) {
      context.read<AdvertisingBloc>().add(
        CreateAdvertising(imagePath: image.path, isActive: true),
      );
    }
  }

  // Edit advertising
  Future<void> _editAdvertising(AdvertisingModel ad) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null && mounted) {
      context.read<AdvertisingBloc>().add(
        UpdateAdvertising(
          id: ad.id,
          imagePath: image.path,
          isActive: ad.isActive,
        ),
      );
    }
  }

  // Delete advertising
  void _deleteAdvertising(AdvertisingModel ad) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Advertisement'),
        content: const Text(
          'Are you sure you want to delete this advertisement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdvertisingBloc>().add(DeleteAdvertising(ad.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Show options menu
  void _showOptionsMenu(BuildContext context, AdvertisingModel ad) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: _lightGreenActive),
              title: const Text('Edit Image'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _editAdvertising(ad);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _deleteAdvertising(ad);
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(bottomSheetContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveBackgroundColor = isDarkTheme
        ? _darkBackgroundColor
        : Colors.white;
    final Color textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: effectiveBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Advertising',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: kantumruyPro,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _addAdvertising,
            tooltip: 'Add Advertising',
          ),
        ],
      ),
      body: BlocConsumer<AdvertisingBloc, AdvertisingState>(
        listener: (context, state) {
          if (state is AdvertisingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _lightGreenActive,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is AdvertisingError) {
            print("${state.message}");
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(state.message),
            //     backgroundColor: Colors.red,
            //     duration: const Duration(seconds: 2),
            //   ),
            // );
          }
        },
        builder: (context, state) {
          // Handle loading state
          if (state is AdvertisingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (state is AdvertisingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load advertisements',
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdvertisingBloc>().add(
                        const LoadAdvertising(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _lightGreenActive,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // Extract advertising list
          List<AdvertisingModel>? advertisingList;

          if (state is AdvertisingLoaded) {
            advertisingList = state.advertising;
          } else if (state is AdvertisingOperationSuccess) {
            advertisingList = state.advertising;
          }

          // If no data available yet, show empty state
          if (advertisingList == null) {
            return const SizedBox.shrink();
          }

          // Handle empty list
          if (advertisingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Advertisements',
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Display list
          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: advertisingList.length,
              itemBuilder: (context, index) {
                final ad = advertisingList![index];
                return _buildAdvertisingRow(ad, textColor);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvertisingRow(AdvertisingModel ad, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ApiConfig.baseUrl + ad.imageUrl,
              width: 160,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 160,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 160,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),

          Row(
            children: [
              // Switch button - updates in real-time
              Switch(
                value: ad.isActive,
                onChanged: (newValue) {
                  // Immediately update the status
                  context.read<AdvertisingBloc>().add(
                    ToggleActiveStatus(id: ad.id, isActive: newValue),
                  );
                },
                activeColor: _thumbColor,
                activeTrackColor: _lightGreenActive,
                inactiveThumbColor: _thumbColor,
                inactiveTrackColor: _darkGreyInactive,
                trackOutlineColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
                splashRadius: 0,
              ),

              // Options menu button
              IconButton(
                icon: Icon(Icons.more_vert, color: textColor),
                onPressed: () => _showOptionsMenu(context, ad),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
