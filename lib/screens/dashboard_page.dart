import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/transaction_tile.dart';
import '../utils/finance_formatters.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
    required this.onAdd,
    required this.onViewAll,
    super.key,
  });

  final double totalIncome;
  final double totalExpenses;
  final List<FinanceTransaction> transactions;
  final VoidCallback onAdd;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpenses;
    return OrientationBuilder(
      builder: (context, orientation) => LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 720 ||
              orientation == Orientation.landscape &&
                  constraints.maxWidth > 560;
          final content = ConstrainedContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todayLabel(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Olá, Ana Clara',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                BalanceCard(balance: balance),
                const SizedBox(height: 16),
                if (wide)
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Entradas',
                          amount: totalIncome,
                          icon: Icons.north_east,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryCard(
                          title: 'Saídas',
                          amount: totalExpenses,
                          icon: Icons.south_east,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Entradas',
                          amount: totalIncome,
                          icon: Icons.north_east,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Saídas',
                          amount: totalExpenses,
                          icon: Icons.south_east,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MonthlyDivision(transactions: transactions),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RecentTransactions(
                          transactions: transactions.take(3).toList(),
                          onViewAll: onViewAll,
                        ),
                      ),
                    ],
                  )
                else ...[
                  MonthlyDivision(transactions: transactions),
                  const SizedBox(height: 20),
                  RecentTransactions(
                    transactions: transactions.take(4).toList(),
                    onViewAll: onViewAll,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text('Nova transação'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
          return SingleChildScrollView(child: content);
        },
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({required this.balance, super.key});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('SALDO EM CONTA', style: AppTextStyles.eyebrow)),
              const Icon(Icons.visibility_outlined, size: 18, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(balance),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const AppPill(
            text: '+14,2% em comparação a abril',
            color: AppColors.greenLight,
            textColor: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    super.key,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.eyebrow)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title == 'Entradas' ? 'Previsão atingida' : '31% do total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class MonthlyDivision extends StatelessWidget {
  const MonthlyDivision({required this.transactions, super.key});

  final List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final expenses = transactions
        .where((item) => item.type == TransactionType.expense)
        .toList();
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final sorted = totals.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final colors = [AppColors.green, const Color(0xFF73BCA2), const Color(0xFFD2A05B)];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Divisão mensal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Detalhes')),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (var index = 0; index < sorted.length; index++)
                    Expanded(
                      flex:
                          (sorted[index].value / (total == 0 ? 1 : total) * 100)
                              .round()
                              .clamp(1, 100),
                      child: ColoredBox(color: colors[index % colors.length]),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            const Text('Cadastre despesas para acompanhar suas categorias.')
          else
            for (var index = 0; index < sorted.take(4).length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sorted[index].key)),
                    Text(
                      '${(sorted[index].value / (total == 0 ? 1 : total) * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatMoney(sorted[index].value),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    required this.transactions,
    required this.onViewAll,
    super.key,
  });

  final List<FinanceTransaction> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Movimentações recentes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 8),
        for (final transaction in transactions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionTile(transaction: transaction),
          ),
      ],
    );
  }
}
