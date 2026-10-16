import 'package:flutter/material.dart';

import '../data/finance_transaction_repository.dart';
import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/page_header.dart';
import 'add_transaction_page.dart';
import 'dashboard_page.dart';
import 'reports_page.dart';
import 'transactions_page.dart';

class FinanceHome extends StatefulWidget {
  const FinanceHome({required this.repository, super.key});

  final FinanceTransactionRepository repository;

  @override
  State<FinanceHome> createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome> {
  int _selectedIndex = 0;
  List<FinanceTransaction> _transactions = [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final transactions = await widget.repository.loadTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  double get _totalIncome => _transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0, (total, transaction) => total + transaction.amount);

  double get _totalExpenses => _transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0, (total, transaction) => total + transaction.amount);

  void _openTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _addTransaction(FinanceTransaction transaction) async {
    final savedTransaction = await widget.repository.insertTransaction(
      transaction,
    );
    if (!mounted) return;
    setState(() {
      _transactions.insert(0, savedTransaction);
      _selectedIndex = 1;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Lançamento salvo com sucesso.')),
      );
  }

  Future<void> _deleteTransaction(FinanceTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: Text('Deseja excluir "${transaction.title}" do extrato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await widget.repository.deleteTransaction(transaction);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível excluir o lançamento: $error')),
        );
        return;
      }
      if (!mounted) return;
      setState(() => _transactions.remove(transaction));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lançamento excluído.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        totalIncome: _totalIncome,
        totalExpenses: _totalExpenses,
        transactions: _transactions,
        onAdd: () => _openTab(2),
        onViewAll: () => _openTab(1),
      ),
      TransactionsPage(
        transactions: _transactions,
        onDelete: _deleteTransaction,
      ),
      AddTransactionPage(onSave: _addTransaction),
      ReportsPage(
        totalIncome: _totalIncome,
        totalExpenses: _totalExpenses,
        transactions: _transactions,
      ),
    ];
    final currentPage = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _loadError != null
        ? _LoadError(error: _loadError!, onRetry: _loadTransactions)
        : pages[_selectedIndex];
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 760;
            if (!wideLayout) {
              return Column(
                children: [
                  PageHeader(title: _pageTitles[_selectedIndex]),
                  Expanded(child: currentPage),
                ],
              );
            }
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _openTab,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.greenLight,
                  selectedIconTheme: const IconThemeData(color: AppColors.green),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: const TextStyle(color: AppColors.muted),
                  destinations: _railDestinations,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Column(
                    children: [
                      PageHeader(title: _pageTitles[_selectedIndex]),
                      Expanded(child: currentPage),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 760
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _openTab,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.greenLight,
              destinations: _destinations,
            )
          : null,
    );
  }

}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 16),
            const Text('Não foi possível carregar os lançamentos.'),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

const _pageTitles = ['Início', 'Extrato', 'Cadastrar', 'Relatórios'];
const _destinations = [
  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
  NavigationDestination(
    icon: Icon(Icons.receipt_long_outlined),
    label: 'Extrato',
  ),
  NavigationDestination(
    icon: Icon(Icons.add_circle_outline),
    label: 'Cadastrar',
  ),
  NavigationDestination(
    icon: Icon(Icons.bar_chart_outlined),
    label: 'Relatórios',
  ),
];
const _railDestinations = [
  NavigationRailDestination(
    icon: Icon(Icons.home_outlined),
    label: Text('Início'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.receipt_long_outlined),
    label: Text('Extrato'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.add_circle_outline),
    label: Text('Cadastrar'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.bar_chart_outlined),
    label: Text('Relatórios'),
  ),
];
