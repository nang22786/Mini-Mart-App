// lib/screens/product_screen/view/address/address.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mini_mart/bloc/address/address_bloc.dart';
import 'package:mini_mart/bloc/address/address_event.dart';
import 'package:mini_mart/bloc/address/address_state.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/address/address_model.dart';
import 'package:mini_mart/screens/check_out/address/add_edit_address_screen.dart';
import 'package:mini_mart/styles/fonts.dart';

class Address extends StatefulWidget {
  final int? selectedAddressId;
  final Function(AddressModel)? onAddressSelected;

  const Address({super.key, this.selectedAddressId, this.onAddressSelected});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  int? selectedAddressId;
  AddressModel? selectedAddress;

  @override
  void initState() {
    super.initState();
    selectedAddressId = widget.selectedAddressId;
    _loadAddresses();
  }

  void _loadAddresses() {
    final userId = StorageService.getUserId();
    if (userId != null) {
      context.read<AddressBloc>().add(LoadAddressesByUserId(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Change address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: kantumruyPro,
          ),
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadAddresses();
          } else if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AddressCreated || state is AddressUpdated) {
            _loadAddresses();
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            );
          }

          if (state is AddressesLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == addresses.length) {
                        return _buildAddNewAddressButton();
                      }

                      final address = addresses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          key: ValueKey(address.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.5,
                            children: [
                              // Edit Button
                              SlidableAction(
                                onPressed: (context) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditAddressScreen(
                                            address: address,
                                          ),
                                    ),
                                  );
                                },
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                icon: Icons.edit_outlined,
                                label: 'Edit',
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                              ),
                              // Delete Button
                              SlidableAction(
                                onPressed: (context) {
                                  _showDeleteConfirmation(address.id!);
                                },
                                backgroundColor: const Color(0xFFE91E63),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: 'Delete',
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(16),
                                ),
                              ),
                            ],
                          ),
                          child: _buildAddressCard(
                            address: address,
                            isSelected: selectedAddressId == address.id,
                            onTap: () {
                              setState(() {
                                selectedAddressId = address.id;
                                selectedAddress = address;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAddress != null
                          ? () {
                              if (widget.onAddressSelected != null) {
                                widget.onAddressSelected!(selectedAddress!);
                              }
                              Navigator.pop(context, selectedAddress);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildAddressCard({
    required AddressModel address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: kantumruyPro,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: kantumruyPro,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.black, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditAddressScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Add new address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontFamily: kantumruyPro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No addresses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditAddressScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int addressId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AddressBloc>().add(DeleteAddress(addressId));
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
