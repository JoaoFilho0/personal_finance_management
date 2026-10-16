import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/finance_transaction_repository.dart';
import 'screens/finance_home.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.repository = const SqliteFinanceTransactionRepository(),
  });

  final FinanceTransactionRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanças pessoais',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      home: FinanceHome(repository: repository),
    );
  }
}
