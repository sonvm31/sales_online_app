import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';
import 'package:sales_online_app/core/utils/currency_formatter.dart';
import 'package:sales_online_app/core/utils/order_status_helper.dart';
import 'package:sales_online_app/data/models/order_model.dart';
import 'package:sales_online_app/data/services/order_service.dart';
import 'package:sales_online_app/ui/shared/order_tracking_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  final int shopId;

  const OrderManagementScreen({super.key, required this.shopId});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _orderService.fetchOrdersByShop(widget.shopId);
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openDetail(OrderModel order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _OrderDetailScreen(orderId: order.id, orderService: _orderService),
      ),
    );
    await _loadOrders();
  }

  Future<void> _saveInlineStatus(OrderModel order, String status) async {
    final currentStatus = order.status.toUpperCase();
    // 🟢 KHÓA: Nếu đơn đã HỦY hoặc ĐÃ HOÀN TẤT thì không cho lưu nữa
    if (currentStatus == 'CANCELLED' || currentStatus == 'DONE') return;

    setState(() => _isSaving = true);
    try {
      await _orderService.updateOrderStatus(orderId: order.id, status: status);
      await _loadOrders();
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: const Text('Quản lý đơn hàng'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrders,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppColors.primary,
            child: _buildBody(textColor, mutedColor, isDark),
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

  Widget _buildBody(Color textColor, Color mutedColor, bool isDark) {
    if (_isLoading) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
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
            'Không thể tải đơn hàng',
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
          FilledButton(onPressed: _loadOrders, child: const Text('Thử lại')),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 58,
                    color: mutedColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Chưa có đơn hàng',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemBuilder: (context, index) {
        final order = _orders[index];
        final statusUpper = order.status.toUpperCase();
        final bool isLocked = statusUpper == 'CANCELLED' || statusUpper == 'DONE';

        return _OrderCard(
          order: order,
          isDark: isDark,
          isLocked: isLocked,
          onTap: () => _openDetail(order),
          onSaveStatus: (status) => _saveInlineStatus(order, status),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: _orders.length,
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  final bool isDark;
  final bool isLocked;
  final VoidCallback onTap;
  final Future<void> Function(String status) onSaveStatus;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.isLocked,
    required this.onTap,
    required this.onSaveStatus,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  late String _selectedStatus;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status.toUpperCase();
  }

  @override
  void didUpdateWidget(covariant _OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _selectedStatus = widget.order.status.toUpperCase();
      _dirty = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.textLight
        : const Color(0xFF1F2937);
    final mutedColor = widget.isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);

    return Material(
      color: widget.isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Đơn #${widget.order.id}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: widget.isLocked
                          ? null
                          : _dirty
                          ? () async {
                        await widget.onSaveStatus(_selectedStatus);
                        if (!mounted) return;
                        setState(() => _dirty = false);
                      }
                          : null,
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isDark
                        ? AppColors.borderDark
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    dropdownColor: widget.isDark
                        ? AppColors.surfaceDark
                        : Colors.white,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'PENDING',
                        child: Text('Đang chuẩn bị hàng'),
                      ),
                      const DropdownMenuItem(
                        value: 'SHIPPING',
                        child: Text('Đang giao hàng'),
                      ),
                      if (widget.order.status.toUpperCase() == 'DONE')
                        const DropdownMenuItem(
                          value: 'DONE',
                          child: Text('Người nhận đã nhận hàng'),
                        ),
                    ],
                    // 🟢 Vô hiệu hóa Dropdown nếu widget.isLocked = true
                    onChanged: widget.isLocked
                        ? null
                        : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedStatus = value;
                        _dirty =
                            _selectedStatus !=
                                widget.order.status.toUpperCase();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                widget.order.user.fullName.isNotEmpty
                    ? widget.order.user.fullName
                    : widget.order.user.email,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedColor),
              ),
              if (widget.order.status.toUpperCase() == 'CANCELLED') ...[
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng đã hủy, không thể thao tác.',
                  style: TextStyle(
                    color: OrderStatusHelper.color('CANCELLED'),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (widget.order.status.toUpperCase() == 'DONE') ...[
                const SizedBox(height: 8),
                Text(
                  'Người nhận đã xác nhận nhận hàng. Đơn đã hoàn tất.',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: OrderStatusHelper.color(
                        _selectedStatus,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      OrderStatusHelper.label(_selectedStatus),
                      style: TextStyle(
                        color: OrderStatusHelper.color(_selectedStatus),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.vnd(widget.order.totalAmount),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final OrderService orderService;

  const _OrderDetailScreen({required this.orderId, required this.orderService});

  @override
  State<_OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<_OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await widget.orderService.fetchOrderDetail(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _selectedStatus = order.status.toUpperCase();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveStatus() async {
    final order = _order;
    final status = _selectedStatus;
    if (order == null || status == null) return;

    final currentStatus = order.status.toUpperCase();
    if (status == currentStatus || currentStatus == 'CANCELLED' || currentStatus == 'DONE') {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await widget.orderService.updateOrderStatus(
        orderId: order.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _selectedStatus = updated.status.toUpperCase();
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openTracking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackingScreen(
          orderId: widget.orderId,
          role: OrderTrackingRole.seller,
          orderService: widget.orderService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);

    final currentStatus = _order?.status.toUpperCase() ?? '';
    final bool isLocked = currentStatus == 'CANCELLED' || currentStatus == 'DONE';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Chi tiết đơn #${widget.orderId}'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 56, color: mutedColor),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadDetail,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_order != null)
              RefreshIndicator(
                onRefresh: _loadDetail,
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DetailCard(
                      title: 'Khách hàng',
                      child: _DetailRow(
                        label: _order!.user.fullName.isNotEmpty
                            ? _order!.user.fullName
                            : _order!.user.email,
                        value: _order!.user.phone.isNotEmpty
                            ? _order!.user.phone
                            : _order!.user.address,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(
                      title: 'Thông tin đơn',
                      child: Column(
                        children: [
                          _DetailRow(label: 'Mã đơn', value: '#${_order!.id}'),
                          _DetailRow(
                            label: 'Thanh toán',
                            value: _order!.paymentMethod,
                          ),
                          _DetailRow(
                            label: 'Ngày tạo',
                            value: _order!.createdAt == null
                                ? '-'
                                : _formatDateTime(_order!.createdAt!),
                          ),
                          _DetailRow(
                            label: 'Phí ship',
                            value: CurrencyFormatter.vnd(_order!.shippingFee),
                          ),
                          _DetailRow(
                            label: 'Tổng tiền',
                            value: CurrencyFormatter.vnd(_order!.totalAmount),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(
                      title: 'Trạng thái',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'PENDING',
                                child: Text('Đang chuẩn bị hàng'),
                              ),
                              const DropdownMenuItem(
                                value: 'SHIPPING',
                                child: Text('Đang giao hàng'),
                              ),
                              const DropdownMenuItem(
                                value: 'PAID',
                                child: Text('Đã thanh toán'),
                              ),
                              if (currentStatus == 'DONE')
                                const DropdownMenuItem(
                                  value: 'DONE',
                                  child: Text('Người nhận đã nhận hàng'),
                                ),
                            ],
                            // 🟢 Vô hiệu hóa Dropdown nếu đơn đã khóa (CANCELLED hoặc DONE)
                            onChanged: isLocked
                                ? null
                                : (value) =>
                                setState(() => _selectedStatus = value),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              // 🟢 Vô hiệu hóa Nút Lưu nếu đơn đã khóa
                              onPressed: isLocked
                                  ? null
                                  : _selectedStatus == currentStatus
                                  ? null
                                  : _saveStatus,
                              child: const Text('Lưu'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openTracking,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Theo dõi giao hàng'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(
                      title: 'Sản phẩm',
                      child: Column(
                        children: _order!.orderItems
                            .map(
                              (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.quantity} x ${CurrencyFormatter.vnd(item.price)}',
                                  style: TextStyle(color: mutedColor),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
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

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : const Color(0xFF1F2937);
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : const Color(0xFF6B7280);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: mutedColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}