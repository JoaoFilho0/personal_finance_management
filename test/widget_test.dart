import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_management/app.dart';
import 'package:personal_finance_management/data/finance_transaction_repository.dart';
import 'package:personal_finance_management/models/finance_transaction.dart';

class _MemoryFinanceTransactionRepository
    implements FinanceTransactionRepository {
  final List<FinanceTransaction> _transactions = [];
  var _nextId = 1;

  @override
  Future<List<FinanceTransaction>> loadTransactions() async {
    return List.of(_transactions);
  }

  @override
  Future<FinanceTransaction> insertTransaction(
    FinanceTransaction transaction,
  ) async {
    final saved = transaction.copyWith(id: _nextId++);
    _transactions.insert(0, saved);
    return saved;
  }

  @override
  Future<void> deleteTransaction(FinanceTransaction transaction) async {
    _transactions.removeWhere((item) => item.id == transaction.id);
  }
}

void main() {
  testWidgets('shows the finance dashboard and its main sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MyApp(repository: _MemoryFinanceTransactionRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá, Ana Clara'), findsOneWidget);
    expect(find.text('SALDO EM CONTA'), findsOneWidget);
    expect(find.text('Divisão mensal'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('validates and saves a new transaction to the statement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _MemoryFinanceTransactionRepository();
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-transaction')));
    await tester.pumpAndSettle();
    expect(find.text('Informe um valor maior que zero.'), findsOneWidget);
    expect(find.text('Informe uma descrição.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('transaction-description')),
      'Café',
    );
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '18,50',
    );
    await tester.ensureVisible(find.byKey(const Key('save-transaction')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-transaction')));
    await tester.pumpAndSettle();

    expect(find.text('Café'), findsOneWidget);
    expect(find.text('-R\$ 18,50'), findsOneWidget);
    expect(find.text('Lançamento salvo com sucesso.'), findsOneWidget);

    await tester.pumpWidget(
      MyApp(key: UniqueKey(), repository: repository),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Extrato').last);
    await tester.pumpAndSettle();

    expect(find.text('Café'), findsOneWidget);
    expect(repository._transactions, hasLength(1));
  });
}
