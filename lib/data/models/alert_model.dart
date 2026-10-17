import 'package:flutter/material.dart';
import '../../core/theme/arvo_colors.dart';

enum AlertSeverity {
  critico(
    label: 'Crítico',
    color: ArvoColors.erro,
    badgeBg: Color(0xFFFDE8E5),
    icon: Icons.error_outline_rounded,
    priorityRank: 1,
  ),
  atencao(
    label: 'Atenção',
    color: ArvoColors.alerta,
    badgeBg: Color(0xFFFBF4E7),
    icon: Icons.warning_amber_rounded,
    priorityRank: 2,
  ),
  info(
    label: 'Informativo',
    color: ArvoColors.info,
    badgeBg: Color(0xFFE9F3F8),
    icon: Icons.info_outline_rounded,
    priorityRank: 3,
  );

  const AlertSeverity({
    required this.label,
    required this.color,
    required this.badgeBg,
    required this.icon,
    required this.priorityRank,
  });

  final String label;
  final Color color;
  final Color badgeBg;
  final IconData icon;
  final int priorityRank;
}

enum AlertType {
  ruptura(
    displayName: 'Risco de Falta',
    tag: 'Ruptura',
  ),
  vencimento(
    displayName: 'Risco de Vencimento',
    tag: 'Validade',
  ),
  anomalia(
    displayName: 'Consumo Fora do Padrão',
    tag: 'Anomalia',
  ),
  curvaAbc(
    displayName: 'Capital Parado / Excesso',
    tag: 'Curva ABC',
  ),
  variacaoPreco(
    displayName: 'Variação Relevante de Preço',
    tag: 'Custo',
  ),
  duplicidade(
    displayName: 'Inconsistência Cadastral',
    tag: 'Cadastro',
  );

  const AlertType({required this.displayName, required this.tag});
  final String displayName;
  final String tag;
}

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String reasonExplanation; // Justificativa explicável baseada nos dados
  final AlertSeverity severity;
  final AlertType type;
  final String? affectedProductId;
  final String? affectedProductName;
  final String recommendedAction; // Ação sugerida para o produtor
  final double? potentialFinancialImpact; // Prejuízo potencial em R$
  final DateTime timestamp;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reasonExplanation,
    required this.severity,
    required this.type,
    this.affectedProductId,
    this.affectedProductName,
    required this.recommendedAction,
    this.potentialFinancialImpact,
    required this.timestamp,
  });
}
