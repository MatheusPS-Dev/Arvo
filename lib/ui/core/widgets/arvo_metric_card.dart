import 'package:flutter/material.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';
import 'arvo_brand_graphics.dart';

/// Card de KPI / Métrica oficial Arvô (fiel ao Mockup A03-app-celular.html
/// com suporte aos ícones SVG oficiais da marca, algarismos tabulares, altura
/// padronizada e micro-interação de hover/foco sem deslocamento de layout).
class ArvoMetricCard extends StatefulWidget {
  final IconData icon;
  final String? svgIconName;
  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final Color iconColor;
  final Color? iconBgColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const ArvoMetricCard({
    super.key,
    required this.icon,
    this.svgIconName,
    required this.title,
    required this.value,
    this.unit,
    this.subtitle,
    this.iconColor = ArvoColors.folha,
    this.iconBgColor,
    this.valueColor,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<ArvoMetricCard> createState() => _ArvoMetricCardState();
}

class _ArvoMetricCardState extends State<ArvoMetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations ? Duration.zero : ArvoColors.motionFast;

    final borderColor = widget.isHighlighted
        ? widget.iconColor.withValues(alpha: _isHovered ? 0.65 : 0.42)
        : (_isHovered ? ArvoColors.bordaForte : ArvoColors.linha);

    return Semantics(
      button: widget.onTap != null,
      label:
          '${widget.title}: ${widget.value}${widget.unit != null ? " ${widget.unit}" : ""}${widget.subtitle != null ? ". ${widget.subtitle}" : ""}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(minHeight: isMobile ? 108 : 132),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
            border: Border.all(
              color: borderColor,
              width: widget.isHighlighted ? 1.4 : 1.0,
            ),
            boxShadow: _isHovered
                ? ArvoColors.sombraCardHover
                : ArvoColors.sombraCardSuave,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
              hoverColor: ArvoColors.nevoa.withValues(alpha: 0.45),
              splashColor: widget.iconColor.withValues(alpha: 0.08),
              child: Padding(
                padding: isMobile
                    ? const EdgeInsets.all(13)
                    : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cabeçalho do Card: Ícone Vetorial da Marca + Indicador de Ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: isMobile ? 34 : 38,
                          height: isMobile ? 34 : 38,
                          decoration: BoxDecoration(
                            color: widget.iconBgColor ??
                                widget.iconColor.withValues(alpha: 0.11),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: widget.svgIconName != null
                              ? ArvoBrandIcon(
                                  iconName: widget.svgIconName!,
                                  size: isMobile ? 18 : 20,
                                  color: widget.iconColor,
                                  fallbackIcon: widget.icon,
                                )
                              : ExcludeSemantics(
                                  child: Icon(
                                    widget.icon,
                                    size: isMobile ? 18 : 20,
                                    color: widget.iconColor,
                                  ),
                                ),
                        ),
                        if (widget.onTap != null)
                          ExcludeSemantics(
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              size: isMobile ? 14 : 15,
                              color: _isHovered
                                  ? ArvoColors.petroleo
                                  : ArvoColors.musgo.withValues(alpha: 0.50),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // Bloco inferior: Título + Valor + Subtítulo com altura uniforme
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: isMobile ? 11.5 : 12,
                            fontWeight: FontWeight.w500,
                            color: ArvoColors.musgo,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                widget.value,
                                style: ArvoTypography.metricValue.copyWith(
                                  color:
                                      widget.valueColor ?? ArvoColors.petroleo,
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.unit != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                widget.unit!,
                                style: TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: ArvoColors.musgo,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle ?? '',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: isMobile ? 11 : 11.5,
                            fontWeight: FontWeight.w500,
                            color: widget.isHighlighted
                                ? (widget.valueColor ?? ArvoColors.erroTexto)
                                : ArvoColors.musgo,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
