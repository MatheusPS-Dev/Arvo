import 'package:flutter/material.dart';
import '../../../data/models/alert_model.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';
import '../../../core/utils/formatters.dart';

class ArvoAlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onAction;
  final String? actionLabel;

  const ArvoAlertCard({
    super.key,
    required this.alert,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final severity = alert.severity;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severity == AlertSeverity.critico
              ? ArvoColors.erro.withValues(alpha: 0.4)
              : ArvoColors.linha,
          width: severity == AlertSeverity.critico ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra lateral com cor de severidade
              Container(
                width: 6,
                color: severity.color,
              ),

              // Conteúdo do Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: severity.badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(severity.icon, size: 14, color: severity.color),
                                const SizedBox(width: 4),
                                Text(
                                  severity.label.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: ArvoTypography.fontHeading,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: severity.color,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ArvoColors.nevoa,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ArvoColors.linha),
                            ),
                            child: Text(
                              alert.type.tag,
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: ArvoColors.musgo,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (alert.potentialFinancialImpact != null &&
                              alert.potentialFinancialImpact! > 0)
                            Text(
                              Formatters.formatCurrency(alert.potentialFinancialImpact!),
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: severity.color,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Título do Alerta
                      Text(
                        alert.title,
                        style: ArvoTypography.titleSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ArvoColors.grafite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 13,
                          color: ArvoColors.musgo,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Caixa de Justificativa Analítica (O diferencial do desafio)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ArvoColors.nevoa,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ArvoColors.linha.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.psychology_alt_outlined,
                              size: 18,
                              color: ArvoColors.petroleo,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.reasonExplanation,
                                style: const TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ArvoColors.grafite,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ação Recomendada
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                  color: ArvoColors.ambar,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    alert.recommendedAction,
                                    style: const TextStyle(
                                      fontFamily: ArvoTypography.fontBody,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: ArvoColors.petroleo,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onAction != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: onAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: severity == AlertSeverity.critico
                                    ? ArvoColors.erro
                                    : ArvoColors.petroleo,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text(actionLabel ?? 'Resolver'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
