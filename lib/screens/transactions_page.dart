import 'package:flutter/material.dart';

import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/app_ui.dart';
import '../widgets/transaction_tile.dart';
import '../utils/finance_formatters.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    required this.transactions,
    required this.onDelete,
    super.key,
  });

  final List<FinanceTransaction> transactions;
  final Future<void> Function(FinanceTransaction) onDelete;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchController = TextEditingController();
  String _filter = 'Todas';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.transactions.where((transaction) {
      final matchesType =
          _filter == 'Todas' ||
          (_filter == 'Entradas' &&
              transaction.type == TransactionType.income) ||
          (_filter == 'Saídas' && transaction.type == TransactionType.expense);
      final normalizedQuery = _query.toLowerCase().trim();
      final matchesSearch =
          normalizedQuery.isEmpty ||
          transaction.title.toLowerCase().contains(normalizedQuery) ||
          transaction.category.toLowerCase().contains(normalizedQuery) ||
          transaction.amount.toString().contains(normalizedQuery);
      return matchesType && matchesSearch;
    }).toList();
    final incomes = widget.transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = widget.transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return ConstrainedContent(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Buscar por nome, categoria ou valor...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Todas', label: Text('Todas')),
              ButtonSegment(value: 'Entradas', label: Text('Entradas')),
              ButtonSegment(value: 'Saídas', label: Text('Saídas')),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) =>
                setState(() => _filter = selection.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppPill(
                  text: '● Entradas: ${formatMoney(incomes)}',
                  color: Colors.white,
                  textColor: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                  text: '● Saídas: ${formatMoney(expenses)}',
                  color: Colors.white,
                  textColor: AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Nenhum lançamento encontrado.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ObjectKey(transaction),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            await widget.onDelete(transaction);
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: TransactionTile(
                            transaction: transaction,
                            showDate: true,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
