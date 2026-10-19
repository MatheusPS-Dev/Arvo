import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';

/// Renderiza os 9 ícones vetoriais oficiais da identidade visual Arvô
/// (Grade 24px, traço 1.8px, pontas arredondadas) com suporte a tokens de cor
/// e semântica de acessibilidade (UI/UX Pro Max: Vector-Only Assets & Contextual Semantics).
class ArvoBrandIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color color;
  final String? semanticLabel;
  final IconData fallbackIcon;

  const ArvoBrandIcon({
    super.key,
    required this.iconName,
    this.size = 22,
    this.color = ArvoColors.folha,
    this.semanticLabel,
    this.fallbackIcon = Icons.eco_outlined,
  });

  String get _resolvedAssetPath {
    final clean = iconName
        .replaceAll('.svg', '')
        .replaceAll('-petroleo', '')
        .replaceAll('-branco', '');
    return 'assets/icons/$clean-petroleo.svg';
  }

  @override
  Widget build(BuildContext context) {
    final svgWidget = SvgPicture.asset(
      _resolvedAssetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => Icon(fallbackIcon, size: size, color: color),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return Semantics(
        label: semanticLabel,
        image: true,
        child: ExcludeSemantics(child: svgWidget),
      );
    }

    // Ícone decorativo ao lado de texto visível: oculto da árvore de acessibilidade
    return ExcludeSemantics(child: svgWidget);
  }
}

/// Renderiza o Logotipo Oficial Arvô (Letreiro ou Símbolo) respeitando as
/// regras do Brand Deck (mínimo 80px para letreiro; símbolo pequeno abaixo de 32px).
class ArvoWordmark extends StatelessWidget {
  final double width;
  final bool isReverse;

  const ArvoWordmark({
    super.key,
    this.width = 112,
    this.isReverse = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width < 80 ? 80.0 : width;
    final svgPath = isReverse
        ? 'assets/logos/letreiro/SVG/arvo-letreiro-reverso.svg'
        : 'assets/logos/letreiro/SVG/arvo-letreiro-colorido.svg';
    final pngPath = isReverse
        ? 'assets/logos/letreiro/PNG/arvo-letreiro-reverso.png'
        : 'assets/logos/letreiro/PNG/arvo-letreiro-colorido.png';

    return Semantics(
      label: 'Logotipo Arvô',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: effectiveWidth,
          height: effectiveWidth * 0.40,
          child: SvgPicture.asset(
            svgPath,
            width: effectiveWidth,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Image.asset(
              pngPath,
              width: effectiveWidth,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'arvô',
                    style: ArvoTypography.titleLarge.copyWith(
                      color: isReverse ? ArvoColors.nevoa : ArvoColors.petroleo,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
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

/// Renderiza o Símbolo Oficial Arvô ("ô" com folhas e faixa horizonte),
/// usando automaticamente `simbolo-pequeno` para tamanhos <= 32px.
class ArvoSymbol extends StatelessWidget {
  final double size;
  final bool isReverse;
  final Color? monochromeColor;

  const ArvoSymbol({
    super.key,
    this.size = 36,
    this.isReverse = true,
    this.monochromeColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool useSmall = size <= 32;
    final String svgPath = useSmall
        ? (isReverse
            ? 'assets/logos/simbolo-pequeno/SVG/arvo-simbolo-pequeno-reverso.svg'
            : 'assets/logos/simbolo-pequeno/SVG/arvo-simbolo-pequeno-colorido.svg')
        : (isReverse
            ? 'assets/logos/simbolo/SVG/arvo-simbolo-reverso.svg'
            : 'assets/logos/simbolo/SVG/arvo-simbolo-colorido.svg');

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          svgPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: monochromeColor != null
              ? ColorFilter.mode(monochromeColor!, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}

/// Grafismo Oficial Arvô: Curvas de Nível & Faixa Horizonte (Brand Deck Slides 01, 02, 24, 25).
/// Desenha os arcos orgânicos de colinas/curvas de nível com traço progressivo.
class ArvoHorizonArcs extends StatelessWidget {
  final Color strokeColor;
  final double maxOpacity;
  final double height;

  const ArvoHorizonArcs({
    super.key,
    this.strokeColor = ArvoColors.sucesso,
    this.maxOpacity = 0.38,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size(double.infinity, height),
          painter: _ArvoHorizonArcsPainter(
            strokeColor: strokeColor,
            maxOpacity: maxOpacity,
          ),
        ),
      ),
    );
  }
}

class _ArvoHorizonArcsPainter extends CustomPainter {
  final Color strokeColor;
  final double maxOpacity;

  const _ArvoHorizonArcsPainter({
    required this.strokeColor,
    required this.maxOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 5 arcos paralelos fiéis ao SVG .arcs do Arvo-Brand-Deck.html
    for (int i = 0; i < 5; i++) {
      final double progress = i / 4.0;
      final double opacity = (maxOpacity * (1.0 - (progress * 0.65))).clamp(0.03, 1.0);
      final double strokeWidth = 1.6 + (i * 0.65);
      final double yOffset = size.height * (0.45 + (i * 0.13));
      final double controlY = size.height * (0.04 + (i * 0.11));

      final paint = Paint()
        ..color = strokeColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(-20, yOffset)
        ..quadraticBezierTo(size.width * 0.5, controlY, size.width + 20, yOffset);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArvoHorizonArcsPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.maxOpacity != maxOpacity;
  }
}
