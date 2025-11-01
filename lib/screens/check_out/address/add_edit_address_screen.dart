// lib/screens/product_screen/view/address/add_edit_address_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mini_mart/bloc/address/address_bloc.dart';
import 'package:mini_mart/bloc/address/address_event.dart';
import 'package:mini_mart/bloc/address/address_state.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/address/address_model.dart';
import 'package:mini_mart/styles/fonts.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _homeNoController;
  late TextEditingController _streetController;
  late TextEditingController _districtController;
  late TextEditingController _provinceController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool _isLoading = false;
  bool _showMap = false;
  String? _selectedLocationAddress;

  GoogleMapController? _mapController;
  GoogleMapController? _previewMapController;
  LatLng _currentPosition = const LatLng(11.5564, 104.9282);
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _homeNoController = TextEditingController(
      text: widget.address?.homeNo ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _districtController = TextEditingController(
      text: widget.address?.district ?? '',
    );
    _provinceController = TextEditingController(
      text: widget.address?.province ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.address?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.address?.longitude.toString() ?? '',
    );

    if (widget.address != null &&
        widget.address!.latitude != 0 &&
        widget.address!.longitude != 0) {
      _currentPosition = LatLng(
        widget.address!.latitude,
        widget.address!.longitude,
      );
      _addMarker(_currentPosition);
      _getAddressFromLatLng(_currentPosition);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _homeNoController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapController?.dispose();
    _previewMapController?.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.address != null;
  bool get _hasCoordinates =>
      _latitudeController.text.isNotEmpty &&
      _longitudeController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          _isEditMode ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: kantumruyPro,
          ),
        ),
      ),
      body: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AddressCreated || state is AddressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Address updated successfully'
                      : 'Address added successfully',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            if (!_showMap)
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Name
                    _buildSectionTitle('Name', Icons.label_outline),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'e.g., Home, Office',
                      icon: Icons.bookmark_border,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter address name';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Location Details
                    _buildSectionTitle(
                      'Location Details',
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _homeNoController,
                            label: 'Home No',
                            hint: '#123',
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _streetController,
                            label: 'Street',
                            hint: 'Street 51',
                            icon: Icons.signpost_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _districtController,
                      label: 'District',
                      hint: 'Chamkar Mon',
                      icon: Icons.location_city_outlined,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _provinceController,
                      label: 'Province',
                      hint: 'Phnom Penh',
                      icon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 24),
                    // LOCATION MAP - Clickable to open full map
                    _buildSectionTitle('Location', Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _showMap = true),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: _hasCoordinates
                                  ? GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          double.parse(
                                            _latitudeController.text,
                                          ),
                                          double.parse(
                                            _longitudeController.text,
                                          ),
                                        ),
                                        zoom: 15,
                                      ),
                                      markers: _markers,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      mapToolbarEnabled: false,
                                      scrollGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      onMapCreated: (controller) {
                                        _previewMapController = controller;
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_location_alt,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Tap to select location',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontFamily: kantumruyPro,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            // Invisible overlay to capture taps
                            Positioned.fill(
                              child: Container(color: Colors.transparent),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),

            // Full Screen Map
            if (_showMap) _buildMapView(),

            // Save Button
            if (!_showMap)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Full Screen Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: _markers,
          onTap: _onMapTapped,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),

        // Top Bar
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => setState(() => _showMap = false),
                ),
              ),

              // GPS Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                ),
              ),
            ],
          ),
        ),

        // Instruction Card (when no marker)
        if (_markers.isEmpty)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Color(0xFF6C5CE7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tap on map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select your delivery location',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Location Info Card (when marker selected)
        if (_markers.isNotEmpty && _selectedLocationAddress != null)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF6C5CE7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedLocationAddress!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: kantumruyPro,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Lat: ${_latitudeController.text}, Lng: ${_longitudeController.text}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Confirm Button
        if (_markers.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _showMap = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Location selected successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF6C5CE7).withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C5CE7), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: kantumruyPro,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, fontFamily: kantumruyPro),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    });
    _addMarker(position);
    await _getAddressFromLatLng(position);
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedLocationAddress =
              '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() => _selectedLocationAddress = 'Address unavailable');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = currentLatLng;
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });
      _addMarker(currentLatLng);
      await _getAddressFromLatLng(currentLatLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      // Check if coordinates are selected
      if (!_hasCoordinates) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a location on the map'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final userId = StorageService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final address = AddressModel(
        id: widget.address?.id,
        userId: userId,
        name: _nameController.text.trim(),
        homeNo: _homeNoController.text.trim().isEmpty
            ? null
            : _homeNoController.text.trim(),
        street: _streetController.text.trim().isEmpty
            ? null
            : _streetController.text.trim(),
        district: _districtController.text.trim().isEmpty
            ? null
            : _districtController.text.trim(),
        province: _provinceController.text.trim().isEmpty
            ? null
            : _provinceController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
      );

      if (_isEditMode) {
        context.read<AddressBloc>().add(
          UpdateAddress(widget.address!.id!, address),
        );
      } else {
        context.read<AddressBloc>().add(CreateAddress(address));
      }
    }
  }
}
