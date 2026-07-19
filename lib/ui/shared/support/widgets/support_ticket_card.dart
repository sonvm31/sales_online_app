import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/data/models/support_ticket_model.dart';

class SupportTicketCard extends StatelessWidget {
  final SupportTicketModel ticket;

  const SupportTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
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
              color: ticket.isResolved
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFFF39C12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TicketHeader(ticket: ticket),
                    const SizedBox(height: 6),
                    _TicketMeta(ticket: ticket),
                    const SizedBox(height: 12),
                    _MessageBox(message: '"${ticket.content}"'),
                    if (ticket.adminReply?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      _AdminReplyBox(reply: ticket.adminReply!),
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

class _TicketHeader extends StatelessWidget {
  final SupportTicketModel ticket;

  const _TicketHeader({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = ticket.isResolved
        ? const Color(0xFF2ECC71)
        : const Color(0xFFF39C12);
    final statusBackground = ticket.isResolved
        ? const Color(0xFFE8F8F5)
        : const Color(0xFFFEF5E7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            ticket.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A1D20),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ticket.isResolved
                ? AppStrings.supportResolved
                : AppStrings.supportPending,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketMeta extends StatelessWidget {
  final SupportTicketModel ticket;

  const _TicketMeta({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${AppStrings.supportTicketCode} #${ticket.id}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const Spacer(),
        const Icon(Icons.access_time, size: 13, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _formatDate(ticket.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String value) {
    return value.length > 10 ? value.substring(0, 10) : value;
  }
}

class _MessageBox extends StatelessWidget {
  final String message;

  const _MessageBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _AdminReplyBox extends StatelessWidget {
  final String reply;

  const _AdminReplyBox({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                AppStrings.supportAdminReply,
                style: TextStyle(
                  color: Color(0xFF3B7CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reply,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
