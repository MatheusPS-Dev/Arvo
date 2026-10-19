import 'package:flutter/material.dart';

/// Design tokens de cores oficiais da marca Arvô (versão 1.0, Outubro 2026).
/// Conforme especificado no Brand Deck, LEIA-ME e arvo-tokens.json,
/// enriquecido com pares de contraste WCAG AA/AAA (UI/UX Pro Max).
class ArvoColors {
  ArvoColors._();

  // ===========================================================================
  // 1. PALETA PRINCIPAL E APOIO OFICIAL (Proporção 55% Névoa / 30% Petróleo / 10% Folha / 5% Âmbar)
  // ===========================================================================
  static const Color petroleo = Color(0xFF0F3D33); // Palavra do logotipo, fundos escuros, botões e títulos (11.3:1 sobre Névoa)
  static const Color folha = Color(0xFF1E9F68); // Folhas do acento, gráficos, ícones e destaques sobre claro
  static const Color ambar = Color(0xFFB28837); // Faixa horizonte do logotipo e detalhes sobre fundo claro
  static const Color nevoa = Color(0xFFF4F8F4); // Fundo principal de tela e palavra no reverso
  static const Color folhaClara = Color(0xFF45B384); // Folhas sobre fundo escuro (4.6:1 sobre Petróleo)
  static const Color ambarClaro = Color(0xFFF2B84B); // Faixa e destaques sobre fundo escuro (6.8:1 sobre Petróleo)

  // ===========================================================================
  // 2. CORES DE INTERFACE, SUPERFÍCIE E TEXTO
  // ===========================================================================
  static const Color petroleoProfundo = Color(0xFF0A2A23); // Fundo escuro de interface / Sidebar / Modais escuros
  static const Color petroleoMarcaDagua = Color(0xFF16574A); // Grafismo marca d'água sobre Petróleo (A04-site.html)
  static const Color grafite = Color(0xFF16221E); // Texto corrido principal (15.3:1 sobre Névoa - AAA)
  static const Color musgo = Color(0xFF5B6B65); // Texto secundário, legendas e rótulos (5.2:1 sobre Névoa - AA)
  static const Color linha = Color(0xFFD5E0DA); // Bordas sutis, divisores e separadores de tabela
  static const Color bordaForte = Color(0xFFC9D6CF); // Bordas de foco secundário / hover em cartões
  static const Color superficieClara = Color(0xFFE9F0EC); // Superfície secundária de agrupamento (A04-site.html)
  static const Color superficieDestaque = Color(0xFFE6EEE9); // Callouts e caixas analíticas (Brand Deck)
  static const Color cardFundo = Colors.white; // Fundo de cartões elevados

  // ===========================================================================
  // 3. CORES SEMÂNTICAS / SISTEMA (Calibradas >= 4.5:1 sobre Névoa no Brand Deck)
  // ===========================================================================
  static const Color sucesso = Color(0xFF188054); // Confirmações, metas atingidas e arcos de horizonte
  static const Color alerta = Color(0xFF8C6B2B); // Prazos, estoque baixo e avisos (kicker oficial)
  static const Color erro = Color(0xFFC0432F); // Ruptura iminente, lote vencendo e ações destrutivas
  static const Color info = Color(0xFF2C7799); // Dicas, unificação cadastral e mensagens neutras

  // Pares de Fundo e Texto Semânticos de Alto Contraste (Brand Deck Slide 19)
  static const Color sucessoFundo = Color(0xFFDDF1E6);
  static const Color sucessoTexto = Color(0xFF17603F);
  static const Color sucessoBorda = Color(0xFFA7DBC0);

  static const Color alertaFundo = Color(0xFFF6EACB);
  static const Color alertaTexto = Color(0xFF76591C);
  static const Color alertaBorda = Color(0xFFE5CA8A);

  static const Color erroFundo = Color(0xFFF3D9D3);
  static const Color erroTexto = Color(0xFF9A3524);
  static const Color erroBorda = Color(0xFFE2ADA1);

  static const Color infoFundo = Color(0xFFE4F1F7);
  static const Color infoTexto = Color(0xFF1D5670);
  static const Color infoBorda = Color(0xFFA8D0E3);

  // ===========================================================================
  // 4. FUNDOS PASTÉIS DE MÓDULOS E ÍCONES (Mockup A06-icone-no-app.html)
  // ===========================================================================
  static const Color pastelLavoura = Color(0xFFE3EEE8);
  static const Color pastelClima = Color(0xFFF2E3C0);
  static const Color pastelEstoque = Color(0xFFDCE6F0);
  static const Color pastelFinanceiro = Color(0xFFEBD9D4);
  static const Color pastelMaquinario = Color(0xFFE4E0EE);
  static const Color pastelRelatorio = Color(0xFFD9ECE8);
  static const Color pastelTalhao = Color(0xFFF0E0E6);
  static const Color pastelAgua = Color(0xFFD7E8F2);
  static const Color iconePastoFundo = pastelLavoura;
  static const Color iconeFinanceiroFundo = pastelFinanceiro;

  // ===========================================================================
  // 5. GRADIENTES E SOMBRAS INSTITUCIONAIS (UI/UX Pro Max)
  // ===========================================================================
  static const LinearGradient gradienteHeroPetroleo = LinearGradient(
    colors: [Color(0xFF134B3F), petroleo, petroleoProfundo],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteSidebarPetroleo = LinearGradient(
    colors: [petroleo, petroleoProfundo],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get sombraCardSuave => [
        BoxShadow(
          color: petroleo.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: petroleo.withValues(alpha: 0.03),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sombraCardHover => [
        BoxShadow(
          color: petroleo.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: petroleo.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get sombraDestaquePetroleo => [
        BoxShadow(
          color: petroleo.withValues(alpha: 0.22),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: petroleo.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get shadowCard => sombraCardSuave;
  static List<BoxShadow> get shadowSm => sombraCardSuave;
  static List<BoxShadow> get shadowMd => sombraCardHover;

  // ===========================================================================
  // 6. TOKENS DE ESPAÇAMENTO, BORDA E MOVIMENTO (8dp Grid & Motion)
  // ===========================================================================
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 999.0;

  static const Duration motionFast = Duration(milliseconds: 140);
  static const Duration motionNormal = Duration(milliseconds: 220);
}
