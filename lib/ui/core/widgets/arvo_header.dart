import 'package:flutter/material.dart';
import '../../../core/theme/arvo_colors.dart';
import '../../../core/theme/arvo_typography.dart';
import 'arvo_brand_graphics.dart';

/// Cabeçalho executivo oficial Arvô:
/// - Em Mobile (< 768px): Exibe o ArvoWordmark reverso no topo, botão Demo e o visual
///   fiel ao mockup mobile A03-app-celular.html.
/// - Em Desktop/Tablet (>= 768px): Não duplica o ArvoWordmark (que já está na Sidebar),
///   renderizando um Executive Page Header limpo sobre Névoa + Hero Card de Capital & Autonomia
///   contido dentro do grid de 1240px.
class ArvoHeader extends StatelessWidget {
  final String farmName;
  final String season;
  final VoidCallback? onResetDemo;
  final VoidCallback? onPrimaryAction;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final Widget? trailing;
  final String? locationBadge;
  final int? criticalAlertsCount;
  final String? totalCapitalText;
  final String? autonomyText;
  final String? riskAtStakeText;

  const ArvoHeader({
    super.key,
    this.farmName = 'Fazenda Boa Vista',
    this.season = 'Safra 2026/27',
    this.onResetDemo,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Simular Safra',
    this.primaryActionIcon = Icons.tune_rounded,
    this.trailing,
    this.locationBadge = 'Sorriso • MT • 842 ha',
    this.criticalAlertsCount,
    this.totalCapitalText,
    this.autonomyText,
    this.riskAtStakeText,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = width >= 768;

    if (isDesktopOrTablet) {
      return _buildDesktopExecutiveHeader(context);
    }
    return _buildMobileHeader(context);
  }

  Widget _buildDesktopExecutiveHeader(BuildContext context) {
    final bool hasCritical =
        criticalAlertsCount != null && criticalAlertsCount! > 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Executive Page Header (sobre fundo Névoa, sem repetir logo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VISÃO GERAL DA OPERAÇÃO',
                          style: ArvoTypography.kicker.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Visão Geral da Safra',
                          style: ArvoTypography.displayMedium.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: ArvoColors.petroleo,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            const Icon(
                              Icons.agriculture_rounded,
                              size: 16,
                              color: ArvoColors.folha,
                            ),
                            Text(
                              farmName,
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: ArvoColors.petroleo,
                              ),
                            ),
                            if (locationBadge != null) ...[
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: ArvoColors.musgo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                locationBadge!,
                                style: const TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 13,
                                  color: ArvoColors.musgo,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (onResetDemo != null)
                        Semantics(
                          button: true,
                          label:
                              'Restaurar cenário de demonstração do Hackathon',
                          child: OutlinedButton.icon(
                            onPressed: onResetDemo,
                            icon: const Icon(Icons.refresh_rounded, size: 17),
                            label: const Text('Restaurar Demo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ArvoColors.petroleo,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              side: const BorderSide(color: ArvoColors.linha),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (onPrimaryAction != null)
                        FilledButton.icon(
                          onPressed: onPrimaryAction,
                          icon: Icon(primaryActionIcon, size: 17),
                          label: Text(primaryActionLabel),
                          style: FilledButton.styleFrom(
                            backgroundColor: ArvoColors.petroleo,
                            foregroundColor: ArvoColors.nevoa,
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: ArvoTypography.fontHeading,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ?trailing,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Hero Card Executivo de Capital & Autonomia (Contido no Grid 1240px)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: ArvoColors.gradienteHeroPetroleo,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: ArvoColors.sombraCardSuave,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        top: -24,
                        child: IgnorePointer(
                          child: ArvoSymbol(
                            size: 190,
                            monochromeColor: ArvoColors.petroleoMarcaDagua
                                .withValues(alpha: 0.42),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: -10,
                        child: SizedBox(
                          height: 68,
                          child: ArvoHorizonArcs(
                            strokeColor: ArvoColors.sucesso,
                            maxOpacity: 0.28,
                            height: 68,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ArvoColors.folhaClara
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: ArvoColors.folhaClara
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: const Text(
                                        'CICLO OPERACIONAL ATIVO',
                                        style: TextStyle(
                                          fontFamily:
                                              ArvoTypography.fontHeading,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ArvoColors.folhaClara,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      season,
                                      style: const TextStyle(
                                        fontFamily: ArvoTypography.fontHeading,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: ArvoColors.nevoa,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ArvoColors.petroleoProfundo
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: (hasCritical
                                              ? ArvoColors.ambarClaro
                                              : ArvoColors.folhaClara)
                                          .withValues(alpha: 0.38),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 14,
                                        color: hasCritical
                                            ? ArvoColors.ambarClaro
                                            : ArvoColors.folhaClara,
                                      ),
                                      const SizedBox(width: 6),
                                      const Flexible(
                                        child: Text(
                                          'Motor Preditivo • 6 Análises em Tempo Real',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily:
                                                ArvoTypography.fontBody,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: ArvoColors.nevoa,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (totalCapitalText != null ||
                                autonomyText != null ||
                                riskAtStakeText != null) ...[
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildHeroMetricItem(
                                        icon: Icons.account_balance_wallet_outlined,
                                        label: 'Capital Total em Estoque',
                                        value: totalCapitalText ?? '—',
                                        valueColor: ArvoColors.nevoa,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 36,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      color:
                                          Colors.white.withValues(alpha: 0.14),
                                    ),
                                    Expanded(
                                      child: _buildHeroMetricItem(
                                        icon: Icons.timelapse_rounded,
                                        label: 'Autonomia Média da Lavoura',
                                        value: autonomyText ?? '—',
                                        valueColor: ArvoColors.folhaClara,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 36,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      color:
                                          Colors.white.withValues(alpha: 0.14),
                                    ),
                                    Expanded(
                                      child: _buildHeroMetricItem(
                                        icon: Icons.shield_outlined,
                                        label:
                                            'Risco Evitável (Validade + ABC)',
                                        value: riskAtStakeText ?? '—',
                                        valueColor: ArvoColors.ambarClaro,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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

  Widget _buildHeroMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExcludeSemantics(
            child: Icon(icon, size: 18, color: valueColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  fontSize: 11.5,
                  color: Color(0xFFBDD0C7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  fontFeatures: ArvoTypography.tabularFigures,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: ArvoColors.gradienteHeroPetroleo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -18,
              child: IgnorePointer(
                child: ArvoSymbol(
                  size: 165,
                  monochromeColor:
                      ArvoColors.petroleoMarcaDagua.withValues(alpha: 0.45),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: -8,
              child: SizedBox(
                height: 76,
                child: ArvoHorizonArcs(
                  strokeColor: ArvoColors.sucesso,
                  maxOpacity: 0.32,
                  height: 76,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ArvoWordmark(
                          width: 92,
                          isReverse: true,
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onResetDemo != null)
                                Semantics(
                                  button: true,
                                  label:
                                      'Restaurar cenário de demonstração do Hackathon',
                                  child: Tooltip(
                                    message:
                                        'Restaurar Cenário de Demonstração',
                                    child: TextButton.icon(
                                      onPressed: onResetDemo,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 15,
                                        color: ArvoColors.nevoa,
                                      ),
                                      label: const Text(
                                        'Demo',
                                        style: TextStyle(
                                          color: ArvoColors.nevoa,
                                          fontFamily:
                                              ArvoTypography.fontHeading,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.12),
                                        foregroundColor: ArvoColors.nevoa,
                                        minimumSize: const Size(72, 36),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        side: BorderSide(
                                          color: Colors.white
                                              .withValues(alpha: 0.18),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              trailing ??
                                  _buildStatusAvatar(criticalAlertsCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          farmName,
                          style: const TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD4E2DC),
                            letterSpacing: 0.15,
                          ),
                        ),
                        if (locationBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ArvoColors.folhaClara
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: ArvoColors.folhaClara,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  locationBadge!,
                                  style: const TextStyle(
                                    fontFamily: ArvoTypography.fontBody,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: ArvoColors.nevoa,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      season,
                      style: ArvoTypography.displayMedium.copyWith(
                        color: ArvoColors.nevoa,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAvatar(int? alerts) {
    final bool hasCritical = alerts != null && alerts > 0;
    return Tooltip(
      message: hasCritical
          ? '$alerts alerta(s) crítico(s) identificado(s)'
          : 'Operação monitorada',
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: hasCritical ? ArvoColors.ambarClaro : ArvoColors.folhaClara,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          hasCritical ? Icons.priority_high_rounded : Icons.check_rounded,
          size: 18,
          color: ArvoColors.petroleoProfundo,
        ),
      ),
    );
  }
}

/// Cabeçalho Editorial de Página (SaaS / AgTech Design System)
/// Usado nas abas internas (Inteligência, Insumos, Movimentações, Simulador)
/// sobre o fundo Névoa, respeitando o grid de 1240px e sem criar barras escuras
/// duplicadas coladas na Sidebar.
/// Em Mobile (< 768px), exibe um cabeçalho nativo enxuto sem repetir botões de
/// navegação que já estão presentes na BottomNavigationBar.
class ArvoPageHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? mobileTrailing;
  final bool allowStandaloneBack;

  const ArvoPageHeader({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.mobileTrailing,
    this.allowStandaloneBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    final canPop = allowStandaloneBack && Navigator.canPop(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: isWide ? 24 : 14,
          bottom: isWide ? 20 : 12,
        ),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canPop) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 4),
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: ArvoColors.petroleo,
                        tooltip: 'Voltar',
                      ),
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kicker,
                          style: ArvoTypography.kicker.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: ArvoTypography.displayMedium.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: ArvoColors.petroleo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 13.5,
                            color: ArvoColors.musgo,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions,
                    ),
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canPop)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: ArvoColors.petroleo,
                            tooltip: 'Voltar',
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kicker,
                              style:
                                  ArvoTypography.kicker.copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: ArvoTypography.titleLarge.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ArvoColors.petroleo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (mobileTrailing != null) ...[
                        const SizedBox(width: 8),
                        mobileTrailing!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: ArvoTypography.fontBody,
                      fontSize: 12,
                      color: ArvoColors.musgo,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
