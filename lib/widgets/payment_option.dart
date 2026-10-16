import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentOption extends StatelessWidget {
  const PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.greenDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: selected ? Colors.white : AppColors.muted),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
