import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/app_ui.dart';
import '../utils/finance_formatters.dart';
import 'dashboard_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
    super.key,
  });

  final double totalIncome;
  final double totalExpenses;
  final List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final remaining = (8000 - totalExpenses).clamp(0, 8000).toDouble();
    final reserve = (20000 * (totalIncome > 0 ? 0.71 : 0)).toDouble();
    final expenses = transactions
        .where((item) => item.type == TransactionType.expense)
        .toList();
    final categories = <String, double>{};
    for (final transaction in expenses) {
      categories.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final sorted = categories.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    return ConstrainedContent(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Visão do mês',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const AppPill(
                text: 'Outubro 2026  ⌄',
                color: Colors.white,
                textColor: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Despesas registradas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(totalExpenses),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                for (var index = 0; index < sorted.length; index++)
                  CategoryProgress(
                    label: sorted[index].key,
                    amount: sorted[index].value,
                    total: totalExpenses,
                    color: index == 0 ? AppColors.green : const Color(0xFF78C6AB),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Metas do mês', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GoalCard(
            title: 'Teto de gastos',
            subtitle:
                '${formatMoney(totalExpenses)} de R\$ 8.000,00 consumidos',
            progress: (totalExpenses / 8000).clamp(0, 1).toDouble(),
            trailing: '${(totalExpenses / 8000 * 100).round()}%',
            footer: 'Dentro do previsto',
            amount: '${formatMoney(remaining)} restante',
          ),
          const SizedBox(height: 12),
          GoalCard(
            title: 'Reserva de emergência',
            subtitle: '${formatMoney(reserve)} de R\$ 20.000,00 poupados',
            progress: (reserve / 20000).clamp(0, 1).toDouble(),
            trailing: '${(reserve / 20000 * 100).round()}%',
            footer: 'Boa! Continue guardando',
            amount: 'Faltam ${formatMoney(20000 - reserve)}',
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ritmo sustentável',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Suas despesas estão dentro do planejado. '
                        'Continue acompanhando seus hábitos financeiros.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class CategoryProgress extends StatelessWidget {
  const CategoryProgress({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
    super.key,
  });

  final String label;
  final double amount;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (amount / total).clamp(0, 1).toDouble();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('${(progress * 100).round()}%'),
              const SizedBox(width: 12),
              Text(formatMoney(amount)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            color: color,
            backgroundColor: AppColors.greenLight,
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.trailing,
    required this.footer,
    required this.amount,
    super.key,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String trailing;
  final String footer;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppPill(text: trailing, color: AppColors.greenLight, textColor: AppColors.green),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.green,
            backgroundColor: AppColors.greenLight,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  footer,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(amount, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
