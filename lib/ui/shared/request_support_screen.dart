import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/logic/support/support_ticket_controller.dart';
import 'package:sales_online_app/main.dart';
import 'package:sales_online_app/ui/shared/support/widgets/support_history_section.dart';
import 'package:sales_online_app/ui/shared/support/widgets/support_request_form.dart';

class RequestSupportScreen extends StatefulWidget {
  final bool isSeller;
  final int? userId;

  const RequestSupportScreen({super.key, required this.isSeller, this.userId});

  @override
  State<RequestSupportScreen> createState() => _RequestSupportScreenState();
}

class _RequestSupportScreenState extends State<RequestSupportScreen> {
  late final SupportTicketController _controller;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int? get _currentUserId => widget.userId ?? authController.session?.userId;

  @override
  void initState() {
    super.initState();
    _controller = SupportTicketController(userId: _currentUserId);
    _controller.loadTickets();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    final submitted = await _controller.submitTicket(
      title: _titleController.text,
      content: _contentController.text,
    );
    if (!mounted) return;

    final message = _controller.errorMessage;
    if (submitted) {
      _titleController.clear();
      _contentController.clear();
      _showSnackBar(AppStrings.supportSubmitSuccess);
      return;
    }

    if (message != null && message.isNotEmpty) {
      _showSnackBar(message);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F8FA),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: Text(
              widget.isSeller
                  ? AppStrings.supportSellerTitle
                  : AppStrings.supportBuyerTitle,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),
          body: RefreshIndicator(
            onRefresh: _controller.loadTickets,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SupportRequestForm(
                    titleController: _titleController,
                    contentController: _contentController,
                    isSubmitting: _controller.isSubmitting,
                    onSubmit: _submitTicket,
                  ),
                  const SizedBox(height: 24),
                  SupportHistorySection(
                    tickets: _controller.tickets,
                    isLoading: _controller.isLoading,
                    errorMessage: _controller.errorMessage,
                    onRetry: _controller.loadTickets,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
