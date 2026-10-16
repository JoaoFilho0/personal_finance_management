import 'package:flutter/material.dart';

import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/app_ui.dart';
import '../utils/finance_formatters.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.showDate = false,
    super.key,
  });

  final FinanceTransaction transaction;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final icon = switch (transaction.category) {
      'Mercado & Feira' => Icons.shopping_cart_outlined,
      'Transporte' => Icons.directions_car_outlined,
      'Lazer' => Icons.movie_outlined,
      'Saúde' => Icons.local_pharmacy_outlined,
      'Moradia' => Icons.home_outlined,
      'Salário' || 'Renda extra' => Icons.account_balance_wallet_outlined,
      _ => Icons.receipt_long_outlined,
    };
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isIncome
                ? AppColors.greenLight
                : const Color(0xFFFFE5E2),
            child: Icon(
              icon,
              color: isIncome ? AppColors.green : AppColors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  showDate
                      ? '${transaction.category} • ${formatDate(transaction.date)}'
                      : transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'}${formatMoney(transaction.amount)}',
            style: TextStyle(
              color: isIncome ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
