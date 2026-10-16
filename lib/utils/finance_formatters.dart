String formatMoney(double amount) {
  final fixed = amount.abs().toStringAsFixed(2).split('.');
  final digits = fixed[0];
  final grouped = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write('.');
    }
    grouped.write(digits[index]);
  }
  return 'R\$ ${amount < 0 ? '-' : ''}${grouped.toString()},${fixed[1]}';
}

double? parseAmount(String input) {
  final normalized = input.trim().replaceAll(' ', '');
  if (normalized.isEmpty) return null;
  final value = normalized.contains(',')
      ? normalized.replaceAll('.', '').replaceAll(',', '.')
      : normalized;
  return double.tryParse(value);
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String todayLabel() {
  const weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  final now = DateTime.now();
  return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
}
