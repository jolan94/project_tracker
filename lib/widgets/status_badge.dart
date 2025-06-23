import 'package:flutter/material.dart';
import 'package:project_tracker/models/project_model.dart';
import 'package:project_tracker/app/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  Color get _statusColor {
    switch (status) {
      case ProjectStatus.building:
        return AppTheme.buildingColor;
      case ProjectStatus.stuck:
        return AppTheme.stuckColor;
      case ProjectStatus.shipped:
        return AppTheme.shippedColor;
      case ProjectStatus.abandoned:
        return AppTheme.abandonedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(large ? 8 : 6),
        border: Border.all(
          color: _statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.emoji,
            style: TextStyle(fontSize: large ? 16 : 14),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: _statusColor,
              fontSize: large ? 16 : 14,
              fontWeight: large ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
