import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_mart/bloc/category/category_bloc.dart';
import 'package:mini_mart/bloc/category/category_event.dart';
import 'package:mini_mart/bloc/category/category_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/category/category_model.dart';
import 'package:mini_mart/styles/fonts.dart';
import 'package:mini_mart/utils/image_url_helper.dart';

class CategoryOwnerScreen extends StatefulWidget {
  const CategoryOwnerScreen({super.key});

  @override
  State<CategoryOwnerScreen> createState() => _CategoryOwnerScreenState();
}

class _CategoryOwnerScreenState extends State<CategoryOwnerScreen> {
  final List<Color> categoryColors = [
    Color(0xFF5DD6C4),
    Color(0xFFFF9F80),
    Color(0xFF88A4FF),
    Color(0xFFFF8ED0),
    Color(0xFFA992FF),
    Color(0xFF6FC5D6),
    Color(0xFF9AE298),
    Color(0xFFFFE566),
    Color(0xFFFFB4A8),
    Color(0xFF94D5FF),
    Color(0xFFD4A5FF),
    Color(0xFFFFD87D),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  void _showAddEditDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            category == null ? 'Add Category' : 'Edit Category',
            style: TextStyle(
              fontFamily: kantumruyPro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        : category != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: ImageUrlHelper.getCategoryImageUrl(
                                ApiConfig.baseUrl + category.image.toString(),
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
                // Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter category name')),
                  );
                  return;
                }

                if (category == null && selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an image')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                if (category == null) {
                  // Create
                  context.read<CategoryBloc>().add(
                    CreateCategoryEvent(
                      name: nameController.text.trim(),
                      imagePath: selectedImage!.path,
                    ),
                  );
                } else {
                  // Update
                  context.read<CategoryBloc>().add(
                    UpdateCategoryEvent(
                      id: category.id,
                      name: nameController.text.trim(),
                      imagePath: selectedImage?.path,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5DD6C4),
              ),
              child: Text(category == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Category',
          style: TextStyle(
            fontFamily: kantumruyPro,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nNote: Make sure no products are using this category.',
          style: TextStyle(fontFamily: kantumruyPro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoryBloc>().add(
                DeleteCategoryEvent(category.id),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
                'Edit Category',
                style: TextStyle(fontFamily: kantumruyPro),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(category: category);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Category',
                style: TextStyle(fontFamily: kantumruyPro),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Categories',
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
                Icons.add_circle_outline_outlined,
                color: Color(0xFF5DD6C4),
                size: 28,
              ),
              onPressed: () => _showAddEditDialog(),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF5DD6C4)),
              );
            }

            if (state is CategoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<CategoryBloc>().add(LoadCategories()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5DD6C4),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CategoryLoaded) {
              final categories = state.categories;

              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No categories available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Color(0xFF5DD6C4),
                onRefresh: () async {
                  context.read<CategoryBloc>().add(RefreshCategories());
                  await Future.delayed(Duration(seconds: 1));
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) => _buildCategoryCard(
                    category: categories[index],
                    color: getCategoryColor(index),
                  ),
                ),
              );
            }

            return Center(
              child: Text(
                'Start loading categories',
                style: TextStyle(fontSize: 16, fontFamily: kantumruyPro),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required Category category,
    required Color color,
  }) {
    final imageUrl = ImageUrlHelper.getCategoryImageUrl(category.image);

    return GestureDetector(
      onLongPress: () => _showOptionsBottomSheet(category),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    child: _buildProductImage(category),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: kantumruyPro,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showOptionsBottomSheet(category),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Category category) {
    if (category.image == null || category.image!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.image, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: "${ApiConfig.baseUrl}${category.image}",

      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFF4757),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
