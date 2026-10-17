import 'package:flutter/material.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';

class ArvoHeader extends StatelessWidget {
  final String farmName;
  final String season;
  final VoidCallback? onResetDemo;
  final Widget? trailing;

  const ArvoHeader({
    super.key,
    this.farmName = 'Fazenda Boa Vista',
    this.season = 'Safra 2026/27',
    this.onResetDemo,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        color: ArvoColors.petroleo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha do Logotipo e Status/Ações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Oficial Arvô
                Image.asset(
                  'assets/logos/letreiro/PNG/arvo-letreiro-reverso.png',
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Row(
                      children: [
                        Text(
                          'arvô',
                          style: ArvoTypography.titleLarge.copyWith(
                            color: ArvoColors.nevoa,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ArvoColors.folhaClara,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                Row(
                  children: [
                    if (onResetDemo != null)
                      Tooltip(
                        message: 'Restaurar Cenário de Demonstração',
                        child: TextButton.icon(
                          onPressed: onResetDemo,
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: ArvoColors.nevoa),
                          label: const Text(
                            'Demo',
                            style: TextStyle(
                              color: ArvoColors.nevoa,
                              fontFamily: ArvoTypography.fontBody,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    trailing ??
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: ArvoColors.folhaClara.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: ArvoColors.petroleo,
                          ),
                        ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Fazenda e Safra
            Text(
              farmName,
              style: const TextStyle(
                fontFamily: ArvoTypography.fontBody,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ArvoColors.nevoa,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              season,
              style: ArvoTypography.titleLarge.copyWith(
                color: ArvoColors.nevoa,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
