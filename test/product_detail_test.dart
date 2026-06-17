import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales_online_app/data/models/product_model.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';
import 'package:sales_online_app/data/services/cart_service.dart';
import 'package:sales_online_app/data/services/product_service.dart';
import 'package:sales_online_app/logic/cart/cart_controller.dart';
import 'package:sales_online_app/ui/buyer/product_detail/product_detail_screen.dart';

void main() {
  test('parses the product detail response', () {
    final product = ProductModel.fromJson(_productJson);

    expect(product.id, 12);
    expect(product.shop.name, 'Góc Nhà Xinh');
    expect(product.shop.avatarUrl, 'https://example.com/shop.png');
    expect(product.category.name, 'Trang trí');
    expect(product.productLine.name, 'Đèn bàn');
    expect(product.price, 125000);
    expect(product.stockQuantity, 8);
  });

  testWidgets('shows product detail and expands its description', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: ProductDetailScreen(
            productId: 12,
            productService: _FakeProductService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đèn bàn tối giản'), findsOneWidget);
    expect(find.text('Kho: 8'), findsOneWidget);
    expect(find.text('125.000đ'), findsOneWidget);
    expect(find.text('Góc Nhà Xinh'), findsOneWidget);
    expect(find.text('Xem thêm'), findsOneWidget);

    await tester.ensureVisible(find.text('Xem thêm'));
    await tester.tap(find.text('Xem thêm'));
    await tester.pumpAndSettle();

    expect(find.text('Thu gọn'), findsOneWidget);
  });

  testWidgets('adds product to cart from the detail screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final cartService = _FakeCartService();
    final cartController = CartController(userId: 7, cartService: cartService);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: ProductDetailScreen(
            productId: 12,
            cartController: cartController,
            productService: _FakeProductService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final addButton = find.text('Thêm vào giỏ hàng');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(cartService.lastUserId, 7);
    expect(cartService.lastProductId, 12);
    expect(cartService.lastQuantity, 1);
    expect(find.text('Thêm vào giỏ hàng thành công'), findsOneWidget);

    cartController.dispose();
  });

  testWidgets('opens the shop from the product detail screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final productService = _FakeProductService();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: ProductDetailScreen(
            productId: 12,
            productService: productService,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewShopButton = find.text('Xem cửa hàng');
    await tester.ensureVisible(viewShopButton);
    await tester.tap(viewShopButton);
    await tester.pumpAndSettle();

    expect(productService.lastShopId, 3);
    expect(find.text('Sản phẩm của cửa hàng'), findsOneWidget);
    expect(find.text('Đèn bàn tối giản'), findsOneWidget);
    expect(find.text('Giỏ hàng'), findsOneWidget);
  });
}

class _FakeProductService extends ProductService {
  int? lastShopId;

  @override
  Future<ProductModel> fetchProductDetail(int productId) async {
    return ProductModel.fromJson(_productJson);
  }

  @override
  Future<Map<String, dynamic>> searchProducts({
    String? keyword,
    int? categoryId,
    int? shopId,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'id',
    String sortDirection = 'asc',
    required int page,
    int size = 10,
  }) async {
    lastShopId = shopId;
    return <String, dynamic>{
      'products': <ProductModel>[ProductModel.fromJson(_productJson)],
      'isLast': true,
    };
  }
}

class _FakeCartService extends CartService {
  int? lastUserId;
  int? lastProductId;
  int? lastQuantity;

  @override
  Future<void> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    lastUserId = userId;
    lastProductId = productId;
    lastQuantity = quantity;
  }

  @override
  Future<List<CartItemModel>> fetchCart(int userId) async {
    return const <CartItemModel>[];
  }
}

final Map<String, dynamic> _productJson = {
  'id': 12,
  'shop': {
    'id': 3,
    'name': 'Góc Nhà Xinh',
    'description': 'Đồ trang trí cho không gian sống hiện đại.',
    'avatarUrl': 'https://example.com/shop.png',
    'isActive': true,
  },
  'category': {
    'id': 4,
    'name': 'Trang trí',
    'description': 'Sản phẩm trang trí nhà cửa.',
  },
  'productLine': {
    'id': 5,
    'category': {
      'id': 4,
      'name': 'Trang trí',
      'description': 'Sản phẩm trang trí nhà cửa.',
    },
    'name': 'Đèn bàn',
    'description': 'Các mẫu đèn bàn.',
  },
  'name': 'Đèn bàn tối giản',
  'description':
      'Thiết kế tối giản phù hợp với phòng ngủ, phòng làm việc và phòng khách. '
      'Ánh sáng dịu mắt, thân đèn chắc chắn, dễ dàng bố trí trong nhiều không '
      'gian khác nhau. Sản phẩm được đóng gói cẩn thận trước khi giao.',
  'price': 125000,
  'stockQuantity': 8,
  'imageUrl': '',
};
