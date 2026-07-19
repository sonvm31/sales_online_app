import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';
import 'package:sales_online_app/data/models/support_ticket_model.dart';
import 'package:sales_online_app/ui/shared/support/widgets/support_ticket_card.dart';

class SupportHistorySection extends StatelessWidget {
  final List<SupportTicketModel> tickets;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SupportHistorySection({
    super.key,
    required this.tickets,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.supportHistoryTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D20),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          _SupportErrorState(message: errorMessage!, onRetry: onRetry)
        else if (tickets.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                AppStrings.supportEmptyHistory,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) =>
                SupportTicketCard(ticket: tickets[index]),
          ),
      ],
    );
  }
}

class _SupportErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SupportErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(AppStrings.supportRetry),
            ),
          ],
        ),
      ),
    );
  }
}
