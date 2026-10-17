import 'dart:math';
import '../../data/models/product_model.dart';
import '../../data/models/alert_model.dart';

class DuplicateCandidateResult {
  final ProductModel productA;
  final ProductModel productB;
  final double similarityScore; // 0.0 a 1.0
  final String suggestedUnifiedName;

  const DuplicateCandidateResult({
    required this.productA,
    required this.productB,
    required this.similarityScore,
    required this.suggestedUnifiedName,
  });
}

class DeduplicationMatcher {
  const DeduplicationMatcher();

  /// Detecta produtos que parecem ser o mesmo item com variações ortográficas ou cadastrais
  List<DuplicateCandidateResult> findDuplicates(
    List<ProductModel> products, {
    double minSimilarity = 0.65,
  }) {
    final candidates = <DuplicateCandidateResult>[];

    for (int i = 0; i < products.length; i++) {
      for (int j = i + 1; j < products.length; j++) {
        final pA = products[i];
        final pB = products[j];

        // Comparar produtos da mesma categoria ou com unidades compatíveis
        if (pA.category == pB.category || pA.unit == pB.unit) {
          final similarity = calculateSimilarity(pA.name, pB.name);

          if (similarity >= minSimilarity) {
            candidates.add(
              DuplicateCandidateResult(
                productA: pA,
                productB: pB,
                similarityScore: similarity,
                suggestedUnifiedName: _suggestName(pA.name, pB.name),
              ),
            );
          }
        }
      }
    }

    return candidates;
  }

  /// Calcula similaridade baseada em n-gramas e tokens normalizados
  double calculateSimilarity(String s1, String s2) {
    final norm1 = _normalize(s1);
    final norm2 = _normalize(s2);

    if (norm1 == norm2) return 1.0;
    if (norm1.isEmpty || norm2.isEmpty) return 0.0;

    // Verificar se um nome está contido dentro do outro
    if (norm1.contains(norm2) || norm2.contains(norm1)) {
      final ratio = min(norm1.length, norm2.length) / max(norm1.length, norm2.length);
      return max(0.85, ratio);
    }

    // Similaridade por tokens desconsiderando números/códigos puros
    final allTokens1 = norm1.split(' ').where((t) => t.isNotEmpty).toSet();
    final allTokens2 = norm2.split(' ').where((t) => t.isNotEmpty).toSet();

    final wordTokens1 = allTokens1.where((t) => !RegExp(r'^\d+$').hasMatch(t)).toSet();
    final wordTokens2 = allTokens2.where((t) => !RegExp(r'^\d+$').hasMatch(t)).toSet();

    final tokens1 = wordTokens1.isNotEmpty ? wordTokens1 : allTokens1;
    final tokens2 = wordTokens2.isNotEmpty ? wordTokens2 : allTokens2;

    final intersection = tokens1.intersection(tokens2).length;
    final union = tokens1.union(tokens2).length;
    final minTokens = min(tokens1.length, tokens2.length);

    final jaccardScore = union > 0 ? (intersection / union) : 0.0;
    final overlapScore = minTokens > 0 ? (intersection / minTokens) : 0.0;
    final tokenScore = max(jaccardScore, overlapScore * 0.85);

    // Distância de Levenshtein normalizada
    final levScore = _levenshteinSimilarity(norm1, norm2);

    // Retorna a melhor evidência de similaridade
    return max(tokenScore, (tokenScore * 0.5) + (levScore * 0.5));
  }

  double _levenshteinSimilarity(String s1, String s2) {
    final dist = _levenshteinDistance(s1, s2);
    final maxLen = max(s1.length, s2.length);
    if (maxLen == 0) return 1.0;
    return (maxLen - dist) / maxLen;
  }

  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        d[i][j] = min(
          min(d[i - 1][j] + 1, d[i][j - 1] + 1),
          d[i - 1][j - 1] + cost,
        );
      }
    }

    return d[m][n];
  }

  String _normalize(String input) {
    var s = input.toLowerCase().trim();
    // Remover acentos básicos em português
    s = s
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _suggestName(String a, String b) {
    // Escolhe a versão mais completa ou limpa
    return a.length >= b.length ? a : b;
  }

  /// Gera alertas para sugestão de unificação cadastral
  List<AlertModel> generateAlerts(List<DuplicateCandidateResult> duplicates) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    for (final dup in duplicates) {
      final pct = (dup.similarityScore * 100).toStringAsFixed(0);
      alerts.add(
        AlertModel(
          id: 'duplicate_${dup.productA.id}_${dup.productB.id}',
          title: 'Possível Inconsistência Cadastral: ${dup.productA.name}',
          description:
              'Produtos "${dup.productA.name}" e "${dup.productB.name}" parecem ser o mesmo item ($pct% de similaridade).',
          reasonExplanation:
              'Detectados dois itens cadastrados com grafias distintas na mesma categoria (${dup.productA.category.displayName}). Saldo A: ${dup.productA.currentStock.toStringAsFixed(0)} ${dup.productA.unit}. Saldo B: ${dup.productB.currentStock.toStringAsFixed(0)} ${dup.productB.unit}. A fragmentação de registros mascara o estoque real total.',
          severity: AlertSeverity.info,
          type: AlertType.duplicidade,
          affectedProductId: dup.productA.id,
          affectedProductName: dup.productA.name,
          recommendedAction:
              'Unificar cadastros sob a nomenclatura sugerida: "${dup.suggestedUnifiedName}".',
          timestamp: now,
        ),
      );
    }

    return alerts;
  }
}
