import 'package:flutter/material.dart';

/// Design tokens de cores oficiais da marca Arvô (versão 1.0, 2026).
/// Conforme especificado no Brand Book e em arvo-tokens.json.
class ArvoColors {
  ArvoColors._();

  // Cores Primárias e Secundárias da Marca
  static const Color petroleo = Color(0xFF0F3D33); // Fundo escuro, títulos, botões principais
  static const Color folha = Color(0xFF1E9F68);    // Destaque verde, ícones, status positivo
  static const Color ambar = Color(0xFFB28837);    // Faixa da marca, detalhes em fundo claro
  static const Color nevoa = Color(0xFFF4F8F4);    // Fundo principal de tela e cartões claros
  static const Color folhaClara = Color(0xFF45B384); // Folha sobre fundo escuro
  static const Color ambarClaro = Color(0xFFF2B84B); // Âmbar sobre fundo escuro e alertas visuais

  // Cores de Interface e Texto
  static const Color petroleoProfundo = Color(0xFF0A2A23); // Superfície de contraste máximo
  static const Color grafite = Color(0xFF16221E);         // Texto corrido e títulos escuros
  static const Color musgo = Color(0xFF5B6B65);           // Texto secundário, legendas e rótulos
  static const Color linha = Color(0xFFD5E0DA);           // Bordas sutis, separadores e linhas de tabela
  static const Color cardFundo = Colors.white;            // Fundo de cards elevados

  // Cores Semânticas / Feedback do Motor de Diagnóstico
  static const Color sucesso = Color(0xFF188054); // Situação normal / meta atingida
  static const Color alerta = Color(0xFF8C6B2B);  // Atenção / prazo / estoque baixo
  static const Color erro = Color(0xFFC0432F);    // Crítico / ruptura iminente / anomalia grave
  static const Color info = Color(0xFF2C7799);    // Informativo / dica / unificação cadastral
}
