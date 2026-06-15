import 'package:flutter/material.dart';

import '../../../../core/aegis/domain/routing_info.dart';
import '../../../../core/theme/app_colors.dart';

class RoutingPanel extends StatelessWidget {
  const RoutingPanel({super.key, required this.routing});

  final RoutingInfo routing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aegis Core',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 8),
          _Row(label: 'Detected Task Type', value: routing.taskType),
          const SizedBox(height: 4),
          _Row(label: 'Selected Provider', value: routing.selectedProvider),
          const SizedBox(height: 4),
          _Row(label: 'Execution Status', value: routing.executionStatus),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
