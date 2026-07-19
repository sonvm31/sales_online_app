import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_strings.dart';

class SupportRequestForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const SupportRequestForm({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppStrings.supportNewRequest,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D20),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: AppStrings.supportTitleHint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              fillColor: const Color(0xFFF5F6F8),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppStrings.supportContentHint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              fillColor: const Color(0xFFF5F6F8),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B7CFF),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF3B7CFF).withValues(alpha: 0.4),
            ),
            onPressed: isSubmitting ? null : onSubmit,
            child: Text(
              isSubmitting
                  ? AppStrings.supportSubmitting
                  : AppStrings.supportSubmitButton,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
