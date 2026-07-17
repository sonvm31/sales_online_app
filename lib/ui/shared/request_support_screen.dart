import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_config.dart';

class SupportTicket {
  final int id;
  final String title;
  final String date;
  final String message;
  final String? adminReply;
  final bool isResolved;

  SupportTicket({
    required this.id,
    required this.title,
    required this.date,
    required this.message,
    this.adminReply,
    required this.isResolved,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? '',
      date: json['createdAt'] ?? '',
      message: json['content'] ?? '',
      adminReply: json['adminReply'],
      isResolved: json['status'] == 'RESOLVED',
    );
  }
}

class RequestSupportScreen extends StatefulWidget {
  final bool isSeller;

  const RequestSupportScreen({super.key, required this.isSeller});

  @override
  State<RequestSupportScreen> createState() => _RequestSupportScreenState();
}

class _RequestSupportScreenState extends State<RequestSupportScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  List<SupportTicket> _tickets = [];
  bool _isLoading = true;

  final Dio _dio = Dio();
  final int _currentUserId = 1;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${ApiConfig.baseUrl}/support-requests?userId=$_currentUserId';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;

        setState(() {
          _tickets = responseData.map((json) => SupportTicket.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Mã lỗi hệ thống: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Không thể lấy lịch sử hỗ trợ: $e');
    }
  }

  Future<void> _submitTicket() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin yêu cầu!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${ApiConfig.baseUrl}/support-requests?userId=$_currentUserId';

      final response = await _dio.post(
        url,
        data: {
          "userId": _currentUserId,
          "title": _titleController.text,
          "content": _descController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _titleController.clear();
        _descController.clear();
        _showSnackBar('Gửi yêu cầu hỗ trợ thành công!');
        _fetchTickets();
      } else {
        throw Exception('Lỗi phản hồi từ server (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Gửi yêu cầu thất bại: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Hỗ trợ khách hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gửi yêu cầu mới',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1D20)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề hỗ trợ',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      fillColor: const Color(0xFFF5F6F8),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết vấn đề của bạn...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      fillColor: const Color(0xFFF5F6F8),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B7CFF),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      shadowColor: const Color(0xFF3B7CFF).withValues(alpha: 0.4),
                    ),
                    onPressed: _isLoading ? null : _submitTicket,
                    child: const Text(
                      'Gửi yêu cầu ngay',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DANH SÁCH LỊCH SỬ TICKET
            const Text(
              'Lịch sử hỗ trợ (Tickets)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1D20)),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                : _tickets.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('Bạn chưa có lịch sử hỗ trợ nào.', style: TextStyle(color: Colors.grey)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(_tickets[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              color: ticket.isResolved ? const Color(0xFF2ECC71) : const Color(0xFFF39C12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ticket.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1D20)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ticket.isResolved ? const Color(0xFFE8F8F5) : const Color(0xFFFEF5E7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket.isResolved ? 'Đã giải quyết' : 'Chờ xử lý',
                            style: TextStyle(
                              color: ticket.isResolved ? const Color(0xFF2ECC71) : const Color(0xFFF39C12),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Mã: #${ticket.id}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const Spacer(),
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket.date.length > 10 ? ticket.date.substring(0, 10) : ticket.date,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"${ticket.message}"',
                        style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, height: 1.4),
                      ),
                    ),
                    if (ticket.adminReply != null && ticket.adminReply!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.support_agent, color: Color(0xFF3B7CFF), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Admin phản hồi:',
                                  style: TextStyle(color: Color(0xFF3B7CFF), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.adminReply!,
                              style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}