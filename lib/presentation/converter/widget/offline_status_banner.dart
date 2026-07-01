import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({
    required this.lastUpdated,
    required this.isUsingCachedData,
    super.key,
  });

  final DateTime? lastUpdated;
  final bool isUsingCachedData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat.yMMMd().add_jm();
    final lastUpdatedLabel = lastUpdated == null
        ? 'Unknown'
        : formatter.format(lastUpdated!.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isUsingCachedData
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            isUsingCachedData ? Icons.cloud_off : Icons.cloud_done,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUsingCachedData
                  ? 'Using cached data · Last updated $lastUpdatedLabel'
                  : 'Last updated $lastUpdatedLabel',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
