import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/data/models/category_model.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/services/category_service.dart';
import 'package:sales_online_app/data/services/product_service.dart';
import 'package:sales_online_app/data/services/product_line_service.dart';

class ProductManagementScreen extends StatefulWidget {
  final bool startWithCreate;
  final int shopId;
  final String shopName;

  const ProductManagementScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    this.startWithCreate = false,
  });

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final ProductLineService _productLineService = ProductLineService();

  List<ProductModel> _products = <ProductModel>[];
  List<CategoryModel> _categories = <CategoryModel>[];
  List<ProductLineModel> _productLines = <ProductLineModel>[];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _productService.fetchShopProducts(widget.shopId),
        _categoryService.fetchCategories(),
        _productLineService.fetchProductLines(),
      ]);

      if (!mounted) return;
      setState(() {
        _products = results[0] as List<ProductModel>;
        _categories = results[1] as List<CategoryModel>;
        _productLines = results[2] as List<ProductLineModel>;
      });

      if (_productLines.isEmpty) {
        throw Exception(
          'Không có product line nào. Vui lòng kiểm tra /api/product-lines.',
        );
      }

      if (widget.startWithCreate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openProductForm();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProduct(
    _ProductFormData data, {
    ProductModel? editing,
  }) async {
    setState(() => _isSaving = true);

    try {
      final payload = data.toPayload(
        shopId: widget.shopId,
        editingId: editing?.id,
      );

      if (editing == null) {
        await _productService.createProduct(payload);
      } else {
        await _productService.updateProduct(editing.id, payload);
      }

      await _loadData();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _openProductForm({ProductModel? product}) {
    if (_categories.isEmpty || _productLines.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductFormSheet(
          categories: _categories,
          productLines: _productLines,
          product: product,
          shopId: widget.shopId,
          onSave: (data) async {
            Navigator.of(context).pop();
            await _saveProduct(data, editing: product);
          },
        );
      },
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm?'),
          content: Text('Bạn chắc chắn muốn xóa "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() => _isSaving = true);
    try {
      await _productService.deleteProduct(product.id);
      await _loadData();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDark
        : const Color(0xFFF5F7FA);
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(widget.shopName),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _isSaving ? null : _openProductForm,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm sản phẩm'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: _buildBody(isDark, textColor, mutedColor),
          ),
          if (_isSaving)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, Color textColor, Color mutedColor) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 260),
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 96),
          Icon(Icons.cloud_off_outlined, size: 58, color: mutedColor),
          const SizedBox(height: 16),
          Text(
            'Không thể tải sản phẩm',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _loadData, child: const Text('Thử lại')),
        ],
      );
    }

    if (_products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_EmptyProductState(onCreate: _openProductForm)],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _ProductTile(
          product: product,
          isDark: isDark,
          onEdit: () => _openProductForm(product: product),
          onDelete: () => _deleteProduct(product),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: _products.length,
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${product.price.toStringAsFixed(0)}đ • Tồn kho: ${product.stockQuantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sửa',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _EmptyProductState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProductState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Chưa có sản phẩm',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm sản phẩm đầu tiên để bắt đầu quản lý cửa hàng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Đăng sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<ProductLineModel> productLines;
  final ProductModel? product;
  final int shopId;
  final ValueChanged<_ProductFormData> onSave;

  const _ProductFormSheet({
    required this.categories,
    required this.productLines,
    required this.product,
    required this.shopId,
    required this.onSave,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  CategoryModel? _selectedCategory;
  ProductLineModel? _selectedProductLine;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : product.stockQuantity.toString(),
    );
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _selectedCategory = widget.categories.firstWhere(
      (item) => item.id == product?.category.id,
      orElse: () => widget.categories.first,
    );
    _selectedProductLine = _resolveInitialProductLine(product);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập thông tin';
    }
    return null;
  }

  String? _positiveNumber(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return 'Nhập số hợp lệ';
    return null;
  }

  String? _positiveInteger(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return 'Nhập số nguyên hợp lệ';
    return null;
  }

  ProductLineModel? _resolveInitialProductLine(ProductModel? product) {
    if (widget.productLines.isEmpty) return null;

    for (final item in widget.productLines) {
      if (item.id == product?.productLine.id) {
        return item;
      }
    }

    final selectedCategoryId = _selectedCategory?.id;
    if (selectedCategoryId != null) {
      for (final item in widget.productLines) {
        if (item.category.id == selectedCategoryId) {
          return item;
        }
      }
    }

    return widget.productLines.first;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final category = _selectedCategory;
    final productLine = _selectedProductLine;
    if (category == null || productLine == null) return;

    widget.onSave(
      _ProductFormData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        imageUrl: _imageController.text.trim(),
        category: category,
        productLine: productLine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.product != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Sửa sản phẩm' : 'Đăng sản phẩm',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoryModel>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem<CategoryModel>(
                          value: category,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      final matched = widget.productLines.where(
                        (item) => item.category.id == value?.id,
                      );
                      _selectedProductLine = matched.isNotEmpty
                          ? matched.first
                          : null;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Chọn category';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductLineModel>(
                  initialValue: _selectedProductLine,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Product line',
                    prefixIcon: Icon(Icons.line_axis_rounded),
                  ),
                  items: widget.productLines
                      .where(
                        (item) =>
                            _selectedCategory == null ||
                            item.category.id == _selectedCategory!.id,
                      )
                      .map(
                        (productLine) => DropdownMenuItem<ProductLineModel>(
                          value: productLine,
                          child: Text(productLine.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedProductLine = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Chọn product line';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  validator: _requiredText,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  validator: _requiredText,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        validator: _positiveNumber,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        validator: _positiveInteger,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tồn kho',
                          prefixIcon: Icon(Icons.inventory_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Lưu thay đổi' : 'Tạo sản phẩm'),
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

class _ProductFormData {
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String imageUrl;
  final CategoryModel category;
  final ProductLineModel productLine;

  const _ProductFormData({
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
    required this.category,
    required this.productLine,
  });

  Map<String, dynamic> toPayload({required int shopId, int? editingId}) {
    return {
      'id': editingId ?? 0,
      'shop': {
        'id': shopId,
        'name': '',
        'description': '',
        'avatarUrl': '',
        'isActive': true,
        'address': '',
        'latitude': 0,
        'longitude': 0,
      },
      'category': category.toJson(),
      'productLine': productLine.toJson(),
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
    };
  }
}
