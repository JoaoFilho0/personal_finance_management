import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../utils/finance_formatters.dart';
import '../widgets/payment_option.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({required this.onSave, super.key});

  final Future<void> Function(FinanceTransaction) onSave;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _category = 'Mercado & Feira';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  static const _categories = [
    'Mercado & Feira',
    'Moradia',
    'Transporte',
    'Lazer',
    'Saúde',
    'Salário',
    'Renda extra',
    'Transferência',
    'Outros',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (selected != null && mounted) {
      setState(() => _date = selected);
    }
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    final parsedAmount = parseAmount(_amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        FinanceTransaction(
          title: _descriptionController.text.trim(),
          category: _category,
          amount: parsedAmount,
          date: _date,
          type: _type,
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _descriptionController.clear();
      _amountController.clear();
      setState(() {
        _type = TransactionType.expense;
        _category = 'Mercado & Feira';
        _date = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o lançamento: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedContent(
      maxWidth: 680,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  icon: Icon(Icons.south),
                  label: Text('Despesa'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  icon: Icon(Icons.north),
                  label: Text('Receita'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  Text(
                    _type == TransactionType.expense
                        ? 'VALOR DA DESPESA'
                        : 'VALOR DA RECEITA',
                    style: AppTextStyles.eyebrow,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'R\$',
                        style: TextStyle(
                          color: _type == TransactionType.expense
                              ? AppColors.red
                              : AppColors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          key: const Key('transaction-amount'),
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0,00',
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (value) {
                            final amount = parseAmount(value ?? '');
                            if (amount == null || amount <= 0) {
                              return 'Informe um valor maior que zero.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Descrição', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('transaction-description'),
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex.: Aluguel, mercado, salário...',
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe uma descrição.'
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Categoria', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Data do lançamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(formatDate(_date)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft,
                side: BorderSide.none,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Forma de pagamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: PaymentOption(
                    icon: Icons.account_balance,
                    label: 'Corrente',
                    selected: true,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: PaymentOption(
                    icon: Icons.credit_card,
                    label: 'Cartão',
                    selected: false,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: PaymentOption(
                    icon: Icons.payments_outlined,
                    label: 'Dinheiro',
                    selected: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const AppPill(
              text: 'Lançamento sincronizado automaticamente no seu extrato.',
              color: Colors.white,
              textColor: AppColors.muted,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('save-transaction'),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSaving ? 'Salvando...' : 'Salvar lançamento',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.greenDark,
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  _formKey.currentState?.reset();
                  _descriptionController.clear();
                  _amountController.clear();
                  FocusScope.of(context).unfocus();
                },
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
