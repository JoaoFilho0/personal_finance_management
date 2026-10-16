import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            tooltip: 'Notificações',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Você está em dia com suas contas.'),
              ),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.green,
            child: Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
