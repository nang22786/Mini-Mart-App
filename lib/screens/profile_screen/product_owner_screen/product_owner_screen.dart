import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_mart/bloc/category/category_bloc.dart';
import 'package:mini_mart/bloc/category/category_event.dart';
import 'package:mini_mart/bloc/category/category_state.dart';
import 'package:mini_mart/bloc/product/product_bloc.dart';
import 'package:mini_mart/bloc/product/product_event.dart';
import 'package:mini_mart/bloc/product/product_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/category/category_model.dart';
import 'package:mini_mart/model/product/product_model.dart';
import 'package:mini_mart/styles/fonts.dart';
import 'package:mini_mart/utils/image_url_helper.dart';

class ProductOwnerScreen extends StatefulWidget {
  const ProductOwnerScreen({super.key});

  @override
  State<ProductOwnerScreen> createState() => _ProductOwnerScreenState();
}

class _ProductOwnerScreenState extends State<ProductOwnerScreen> {
  // ✅ Cache categories here
  List<Category> _cachedCategories = [];

  @override
  void initState() {
    super.initState();
    // ✅ Load both products and categories on init
    context.read<ProductBloc>().add(LoadProducts());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  void _showAddEditDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final detailController = TextEditingController(text: product?.detail ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock?.qty.toString() ?? '',
    );

    File? selectedImage;
    final ImagePicker picker = ImagePicker();
    int? selectedCategoryId = product?.category?.id;

    // ✅ Check if categories are loaded
    if (_cachedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loading categories, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
            style: TextStyle(
              fontFamily: kantumruyPro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImage = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : product != null && product.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: ImageUrlHelper.getProductImageUrl(
                                ApiConfig.baseUrl + product.image.toString(),
                              ),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.add_photo_alternate, size: 50),
                            ),
                          )
                        : Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to select image',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),

                // Product Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                ),
                SizedBox(height: 12),

                // Detail
                TextField(
                  controller: detailController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 12),

                // Price
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 12),

                // Stock
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                SizedBox(height: 12),

                // ✅ Category Dropdown (uses cached data - INSTANT!)
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _cachedCategories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: TextStyle(fontFamily: kantumruyPro),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // Validation
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter product name')),
                  );
                  return;
                }

                if (priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Please enter price')));
                  return;
                }

                if (stockController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter stock quantity')),
                  );
                  return;
                }

                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }

                if (product == null && selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an image')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                if (product == null) {
                  // Create
                  context.read<ProductBloc>().add(
                    CreateProduct(
                      name: nameController.text.trim(),
                      detail: detailController.text.trim(),
                      price: double.parse(priceController.text.trim()),
                      stock: int.parse(stockController.text.trim()),
                      image: selectedImage!.path,
                      categoryId: selectedCategoryId!,
                    ),
                  );
                } else {
                  // Update
                  context.read<ProductBloc>().add(
                    UpdateProduct(
                      id: product.id,
                      name: nameController.text.trim(),
                      detail: detailController.text.trim(),
                      price: double.parse(priceController.text.trim()),
                      stock: int.parse(stockController.text.trim()),
                      image: selectedImage?.path,
                      categoryId: selectedCategoryId!,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4757),
              ),
              child: Text(product == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: kantumruyPro,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${product.name}"?',
              style: TextStyle(fontFamily: kantumruyPro, fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                'This action cannot be undone!',
                style: TextStyle(
                  fontFamily: kantumruyPro,
                  fontSize: 12,
                  color: Colors.red[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: kantumruyPro,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductBloc>().add(DeleteProduct(product.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit, color: Color(0xFF4CAF50)),
                title: Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: kantumruyPro,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEditDialog(product: product);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: kantumruyPro,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(product);
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: kantumruyPro,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Color(0xFFFF4757),
              size: 28,
            ),
            onPressed: () => _showAddEditDialog(),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // ✅ Listen to CategoryBloc to cache categories
          BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryLoaded) {
                setState(() {
                  _cachedCategories = state.categories;
                });
                print('✅ Cached ${_cachedCategories.length} categories');
              }
            },
          ),
          // Listen to ProductBloc for operations
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ProductError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4757)),
              );
            }

            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProducts());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF4757),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductLoaded) {
              final products = state.products;

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: Icon(Icons.add),
                        label: Text('Add First Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4757),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Color(0xFFFF4757),
                onRefresh: () async {
                  context.read<ProductBloc>().add(RefreshProducts());
                  await Future.delayed(Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index]);
                  },
                ),
              );
            }

            return Center(
              child: Text(
                'Start loading products',
                style: TextStyle(fontSize: 16, fontFamily: kantumruyPro),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final imageUrl = ImageUrlHelper.getProductImageUrl(product.image);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: _buildProductImage(product),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: kantumruyPro,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Category
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category?.name ?? 'No Category',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF4757),
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Price and Stock
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4757),
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (product.stock?.qty ?? 0) > 50
                          ? Colors.green.withOpacity(0.1)
                          : (product.stock?.qty ?? 0) > 20
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stock: ${product.stock?.qty ?? 0}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (product.stock?.qty ?? 0) > 50
                            ? Colors.green
                            : (product.stock?.qty ?? 0) > 20
                            ? Colors.orange
                            : Colors.red,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          Container(
            margin: EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _showOptionsBottomSheet(product),
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.image == null || product.image!.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: Icon(Icons.image, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: "${ApiConfig.baseUrl}${product.image}",
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFF4757),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
