import 'package:flutter/material.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';

class ArvoMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  const ArvoMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
    this.iconColor = ArvoColors.folha,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ArvoColors.linha.withValues(alpha: 0.8), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ArvoColors.musgo,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: ArvoTypography.metricValue.copyWith(
                        color: valueColor ?? ArvoColors.petroleo,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit!,
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ArvoColors.musgo,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
