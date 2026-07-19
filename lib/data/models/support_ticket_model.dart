class SupportTicketModel {
  final int id;
  final int? userId;
  final String title;
  final String createdAt;
  final String content;
  final String? adminReply;
  final String status;

  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.content,
    required this.status,
    this.adminReply,
  });

  bool get isResolved => status.toUpperCase() == 'RESOLVED';

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: _parseUserId(json),
      title: (json['title'] as String?) ?? '',
      createdAt: (json['createdAt'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      adminReply: json['adminReply'] as String?,
      status: (json['status'] as String?) ?? '',
    );
  }

  static int? _parseUserId(Map<String, dynamic> json) {
    final directUserId = json['userId'];
    if (directUserId is num) return directUserId.toInt();

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final nestedUserId = user['id'];
      if (nestedUserId is num) return nestedUserId.toInt();
    }

    final customer = json['customer'];
    if (customer is Map<String, dynamic>) {
      final nestedUserId = customer['id'];
      if (nestedUserId is num) return nestedUserId.toInt();
    }

    return null;
  }
}
