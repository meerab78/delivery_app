// Add / edit a product: picture, name, price, category, description, switches.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/product_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../controller.dart';
import '../model/admin_category_model.dart';
import '../model/admin_product_model.dart';

class ProductFormView extends ConsumerStatefulWidget {
  // product == null  -> add a new product
  // product != null  -> edit this product
  const ProductFormView({super.key, this.product});

  final AdminProductModel? product;

  @override
  ConsumerState<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends ConsumerState<ProductFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  String? _categoryId;
  bool _inStock = true;
  bool _isActive = true;
  File? _newImage; // the picture the admin just picked (not uploaded yet)

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    String priceText = '';
    if (product != null) {
      if (product.price % 1 == 0) {
        priceText = product.price.toStringAsFixed(0);
      } else {
        priceText = product.price.toString();
      }
    }

    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(text: priceText);
    _descriptionController =
        TextEditingController(text: product?.description ?? '');

    if (product != null) {
      _categoryId = product.categoryId;
      _inStock = product.inStock;
      _isActive = product.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Opens the phone gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // smaller picture = faster upload
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _newImage = File(picked.path);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text.trim());

    final error = await ref.read(adminCatalogControllerProvider.notifier).saveProduct(
      productId: widget.product?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      categoryId: _categoryId!,
      inStock: _inStock,
      isActive: _isActive,
      newImage: _newImage,
      oldImageUrl: widget.product?.imageUrl,
    );

    if (!mounted) return;

    if (error != null) {
      showSnack(context, error);
      return;
    }

    showSnack(context, _isEdit ? 'Product updated' : 'Product added');
    Navigator.of(context).pop();
  }

  // The big picture box at the top
  Widget _buildImageBox() {
    final newImage = _newImage;
    final oldUrl = widget.product?.imageUrl;

    Widget picture;
    if (newImage != null) {
      picture = Image.file(
        newImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: 180,
      );
    } else if (oldUrl != null && oldUrl.isNotEmpty) {
      picture = ProductImage(
        imageUrl: oldUrl,
        name: _nameController.text,
        width: double.infinity,
        height: 180,
      );
    } else {
      picture = Container(
        color: AppColors.primarySoft,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 44,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                'Tap to add a photo',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF6F6F6),
                  child: picture,
                ),
              ),
              // Small "edit" badge in the corner
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(adminCatalogControllerProvider).isLoading;
    final categories =
        ref.watch(adminCategoriesProvider).value ?? <AdminCategoryModel>[];

    // Build the dropdown items with a simple loop
    final items = <DropdownMenuItem<String>>[];
    String? selectedCategory;
    for (final category in categories) {
      items.add(
        DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        ),
      );
      if (category.id == _categoryId) {
        selectedCategory = category.id;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit product' : 'Add product')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageBox(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Product name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (${AppConstants.currency})',
                    ),
                    validator: (value) {
                      final price = double.tryParse((value ?? '').trim());
                      if (price == null || price <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: items,
                    decoration: const InputDecoration(labelText: 'Category'),
                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please choose a category';
                      }
                      return null;
                    },
                  ),
                  // Helpful hint when there is no category yet
                  if (categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'No categories yet. Add one from the Categories button on the Products screen.',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In stock'),
                    value: _inStock,
                    onChanged: (value) {
                      setState(() {
                        _inStock = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Visible to customers'),
                    subtitle: const Text('Turn off to hide this product'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    child: saving
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : Text(_isEdit ? 'Save changes' : 'Add product'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}