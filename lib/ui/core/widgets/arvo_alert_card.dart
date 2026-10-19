import 'package:flutter/material.dart';
import '../../../data/models/alert_model.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';
import '../../../core/utils/formatters.dart';

/// Card de Diagnóstico Explicável do Arvô.
/// Segue as diretrizes UI/UX Pro Max:
/// - Semântica multi-pista (cor + ícone + rótulo textual de severidade + tag de motor)
/// - Contraste WCAG AA (>= 4.5:1) usando os pares semânticos do Brand Deck Slide 19
/// - Algarismos tabulares para impacto financeiro em R$
/// - Touch target >= 44px no botão de ação recomendada
class ArvoAlertCard extends StatefulWidget {
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
  State<ArvoAlertCard> createState() => _ArvoAlertCardState();
}

class _ArvoAlertCardState extends State<ArvoAlertCard> {
  bool _isHovered = false;

  Color _resolveBadgeTextColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critico:
        return ArvoColors.erroTexto;
      case AlertSeverity.atencao:
        return ArvoColors.alertaTexto;
      case AlertSeverity.info:
        return ArvoColors.infoTexto;
    }
  }

  Color _resolveBadgeBgColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critico:
        return ArvoColors.erroFundo;
      case AlertSeverity.atencao:
        return ArvoColors.alertaFundo;
      case AlertSeverity.info:
        return ArvoColors.infoFundo;
    }
  }

  IconData _resolveTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.ruptura:
        return Icons.trending_down_rounded;
      case AlertType.vencimento:
        return Icons.event_busy_rounded;
      case AlertType.anomalia:
        return Icons.query_stats_rounded;
      case AlertType.curvaAbc:
        return Icons.pie_chart_outline_rounded;
      case AlertType.variacaoPreco:
        return Icons.price_change_outlined;
      case AlertType.duplicidade:
        return Icons.merge_type_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final severity = alert.severity;
    final badgeTextColor = _resolveBadgeTextColor(severity);
    final badgeBgColor = _resolveBadgeBgColor(severity);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          'Alerta ${severity.label} de ${alert.type.displayName}: ${alert.title}. ${alert.description}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: disableAnimations ? Duration.zero : ArvoColors.motionFast,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
            border: Border.all(
              color: severity == AlertSeverity.critico
                  ? ArvoColors.erro.withValues(alpha: _isHovered ? 0.65 : 0.42)
                  : (_isHovered ? ArvoColors.bordaForte : ArvoColors.linha),
              width: severity == AlertSeverity.critico ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered
                ? ArvoColors.sombraCardHover
                : ArvoColors.sombraCardSuave,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra lateral de severidade
                  Container(
                    width: 6,
                    color: severity.color,
                  ),

                  // Corpo do Diagnóstico
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Linha 1: Badges de Severidade, Tipo de Motor e Impacto Financeiro
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Badge de Severidade (Ícone + Texto com contraste WCAG AA)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeBgColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ExcludeSemantics(
                                          child: Icon(
                                            severity.icon,
                                            size: 14,
                                            color: badgeTextColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          severity.label.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: ArvoTypography.fontHeading,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: badgeTextColor,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Badge do Motor Analítico
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ArvoColors.nevoa,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: ArvoColors.linha),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ExcludeSemantics(
                                          child: Icon(
                                            _resolveTypeIcon(alert.type),
                                            size: 13,
                                            color: ArvoColors.petroleo,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          alert.type.tag,
                                          style: const TextStyle(
                                            fontFamily: ArvoTypography.fontBody,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: ArvoColors.petroleo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Impacto Financeiro Potencial (Algarismos Tabulares)
                              if (alert.potentialFinancialImpact != null &&
                                  alert.potentialFinancialImpact! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBgColor.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: badgeTextColor.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ExcludeSemantics(
                                        child: Icon(
                                          Icons.paid_outlined,
                                          size: 13,
                                          color: badgeTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Risco: ${Formatters.formatCurrency(alert.potentialFinancialImpact!)}',
                                        style: TextStyle(
                                          fontFamily: ArvoTypography.fontHeading,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: badgeTextColor,
                                          fontFeatures: ArvoTypography.tabularFigures,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Título do Diagnóstico
                          Text(
                            alert.title,
                            style: ArvoTypography.titleSmall.copyWith(
                              fontSize: 16,
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
                              fontWeight: FontWeight.w500,
                              color: ArvoColors.musgo,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Caixa de Justificativa Explicável (Baseada nos dados históricos)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ArvoColors.nevoa,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ArvoColors.linha,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: ArvoColors.superficieDestaque,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const ExcludeSemantics(
                                    child: Icon(
                                      Icons.psychology_alt_outlined,
                                      size: 16,
                                      color: ArvoColors.petroleo,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'JUSTIFICATIVA DO MOTOR ANALÍTICO',
                                        style: TextStyle(
                                          fontFamily: ArvoTypography.fontHeading,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ArvoColors.petroleo,
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        alert.reasonExplanation,
                                        style: const TextStyle(
                                          fontFamily: ArvoTypography.fontBody,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                          color: ArvoColors.grafite,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Plano de Ação Recomendado + CTA com Touch Target >= 44px
                          Builder(
                            builder: (context) {
                              final isCompactMobile =
                                  MediaQuery.sizeOf(context).width < 560;
                              final recommendationRow = Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: ExcludeSemantics(
                                      child: Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 16,
                                        color: ArvoColors.alerta,
                                      ),
                                    ),
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
                                        height: 1.35,
                                      ),
                                      maxLines: isCompactMobile ? 4 : 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );

                              Widget buildCtaButton() {
                                return ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 40),
                                  child: ElevatedButton.icon(
                                    onPressed: widget.onAction,
                                    icon: Icon(
                                      alert.type == AlertType.duplicidade
                                          ? Icons.merge_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: 15,
                                    ),
                                    label:
                                        Text(widget.actionLabel ?? 'Resolver'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          severity == AlertSeverity.critico
                                              ? ArvoColors.erro
                                              : ArvoColors.petroleo,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      textStyle: const TextStyle(
                                        fontFamily: ArvoTypography.fontHeading,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (isCompactMobile) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    recommendationRow,
                                    if (widget.onAction != null) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: buildCtaButton(),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: recommendationRow),
                                  if (widget.onAction != null) ...[
                                    const SizedBox(width: 12),
                                    buildCtaButton(),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
