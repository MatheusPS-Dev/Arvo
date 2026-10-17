import 'package:flutter/material.dart';
import '../../core/theme/arvo_colors.dart';

enum ProductCategory {
  fertilizantes(
    displayName: 'Fertilizantes',
    description: 'Ureia, KCl, MAP, NPKs, Sulfato de amônio, micronutrientes',
    iconName: 'icone-lavoura',
    color: ArvoColors.folha,
  ),
  corretivos(
    displayName: 'Corretivos',
    description: 'Calcário dolomítico, gesso agrícola',
    iconName: 'icone-talhao',
    color: Color(0xFF6E8B7B),
  ),
  sementes(
    displayName: 'Sementes',
    description: 'Milho, soja, feijão, braquiária',
    iconName: 'icone-lavoura',
    color: ArvoColors.ambar,
  ),
  defensivosEBbiologicos(
    displayName: 'Defensivos e Biológicos',
    description: 'Herbicidas, fungicidas, inseticidas, biológicos e inoculantes',
    iconName: 'icone-clima',
    color: Color(0xFF2C7799),
  ),
  combustiveisELubrificantes(
    displayName: 'Combustíveis e Lubrificantes',
    description: 'Óleo diesel S10, óleo motor, óleo hidráulico, graxa',
    iconName: 'icone-maquinario',
    color: Color(0xFF8C6B2B),
  ),
  pecasEManutencao(
    displayName: 'Peças e Manutenção',
    description: 'Filtros, correias, rolamentos, bicos de pulverização',
    iconName: 'icone-maquinario',
    color: Color(0xFF5B6B65),
  ),
  materiaisDeIrrigacao(
    displayName: 'Materiais de Irrigação',
    description: 'Tubos PVC, mangueira de gotejamento, conexões, registros',
    iconName: 'icone-agua',
    color: Color(0xFF3B82A6),
  ),
  epiEDiversos(
    displayName: 'EPI e Materiais Diversos',
    description: 'Luvas, respiradores, óculos, aventais, sacos e estacas',
    iconName: 'icone-estoque',
    color: Color(0xFF7A6A53),
  );

  const ProductCategory({
    required this.displayName,
    required this.description,
    required this.iconName,
    required this.color,
  });

  final String displayName;
  final String description;
  final String iconName;
  final Color color;

  static ProductCategory fromString(String name) {
    return ProductCategory.values.firstWhere(
      (c) => c.displayName.toLowerCase() == name.toLowerCase() ||
             c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => ProductCategory.fertilizantes,
    );
  }
}
