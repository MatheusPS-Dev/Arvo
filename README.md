# 🌿 Arvô — Gestão Inteligente de Insumos Agrícolas

Aplicativo desenvolvido para o **Desafio Agronomia (AgroHack)**, focado em transformar a gestão de insumos rurais em uma operação preditiva, reduzindo desperdícios financeiros e eliminando rupturas de estoque durante a safra.

---

## 🚀 Visão Geral e Proposta de Valor

Em fazendas de alta produtividade, a falta de visibilidade sobre o consumo de insumos (herbicidas, fertilizantes, sementes, defensivos) gera compras de emergência com sobrepreço ou perdas milionárias por vencimento de lotes no galpão. 

O **Arvô** substitui planilhas reativas por um **motor de inteligência preditiva**, fornecendo respostas imediatas com diagnósticos explicáveis e planos de ação para a tomada de decisão do produtor rural.

---

## 🧠 Motores de Inteligência do Arvô (`lib/domain/engine/`)

O aplicativo conta com 6 motores matemáticos e estatísticos desacoplados:

1. **Previsão de Ruptura (`RunoutCalculator`):**
   - Calcula a taxa de consumo ponderada diária.
   - Projeta a data exata em que o insumo acabará e quantos dias de autonomia a fazenda possui antes da necessidade de recompra.

2. **Risco de Vencimento e Perda Financeira (`ExpiryRiskAnalyzer`):**
   - Cruza a validade dos lotes físicos com a velocidade real de aplicação em campo.
   - Quantifica em **Reais (R$)** o valor financeiro em risco caso o lote não seja remanejado a tempo.

3. **Detecção e Unificação de Duplicidades (`DeduplicationMatcher`):**
   - Utiliza normalização de tokens e distância de Levenshtein para encontrar cadastros duplicados do mesmo produto com nomes ligeiramente diferentes (ex: *Glifosato 480 SL* vs *Glifosato Nortox*).
   - Permite a **unificação instantânea de saldos e históricos** com um clique no app.

4. **Detecção de Anomalias de Consumo (`AnomalyDetector`):**
   - Analisa séries temporais de saídas e sinaliza retiradas com desvio estatístico superior a **2.0 desvios padrão ($\sigma > 2.0$)**, indicando possíveis desvios, erros de aplicação ou vazamentos.

5. **Curva ABC & Capital Estagnado (`AbcCurveAnalyzer`):**
   - Aplica o princípio de Pareto (80/20) para classificar o portfólio em itens A, B e C.
   - Identifica produtos de alto valor financeiro (Classe A) com giro baixo ou nulo, liberando fluxo de caixa para a fazenda.

6. **Simulador de Cenários What-If (`SimulationView`):**
   - Permite ao produtor simular aceleração do ritmo de consumo (+25%, +50%, +100%) e atrasos na entrega dos fornecedores (Lead Time), antecipando pedidos com semanas de antecedência.

---

## 🏛️ Arquitetura do Software (Clean Architecture)

O código foi estruturado em camadas independentes, garantindo manutenibilidade, testabilidade e separação de conceitos:

```
lib/
├── approutes.dart              # Re-export limpo para facilidade de importação
├── core/
│   ├── routes/app_routes.dart  # Gerenciamento centralizado de rotas nomeadas e atalhos tipados
│   ├── theme/                  # Design System Arvô (ArvoColors, ArvoTypography, ArvoTheme)
│   └── utils/formatters.dart   # Formatadores puros de moeda (R$) e datas (pt-BR)
├── data/
│   ├── models/                 # Entidades imutáveis (ProductModel, BatchModel, MovementModel, AlertModel)
│   ├── repositories/           # Repositórios reativos com ChangeNotifier
│   └── sources/agro_mock_data  # Dados realistas da Fazenda Boa Vista (Safra 2026/27)
├── domain/
│   ├── engine/                 # Motores de inteligência matemática (100% isolados de UI)
│   └── viewmodels/             # MVVM desacoplado (StockIntelligenceViewModel)
├── ui/
│   ├── core/widgets/           # Componentes atômicos reutilizáveis (Header, MetricCard, AlertCard)
│   ├── features/               # Módulos por funcionalidade
│   │   ├── dashboard/          # Visão Geral, métricas e radar de prioridades
│   │   ├── intelligence/       # Central de alertas e ação de unificação
│   │   ├── inventory/          # Catálogo de insumos e controle de lotes
│   │   ├── movements/          # Histórico e registro de entradas/saídas
│   │   └── simulation/         # Simulador de cenários What-If
│   └── main_screen.dart        # Layout responsivo adaptativo (Mobile e Web/Desktop)
└── main.dart                   # Entry point e injeção de dependências com Provider
```

---

## 🎨 Identidade Visual (Design System)

- **Cores Oficiais:**
  - `Petróleo Profundo`: `#0F3D33`
  - `Folha Vibrante`: `#1E9F68`
  - `Âmbar Safra`: `#B28837`
  - `Névoa Suave`: `#F4F8F4`
  - `Erro/Alerta Crítico`: `#D9483B`
- **Tipografia Oficial:** Google Fonts *Outfit* (títulos) e *DM Sans* (corpo e números).

---

## 🧪 Testes Automatizados

O projeto conta com **13 testes automatizados** cobrindo todas as camadas:
- Testes unitários dos motores matemáticos e estatísticos (`stock_intelligence_test.dart`).
- Testes de roteamento e integridade das rotas nomeadas (`routes_test.dart`).
- Testes de renderização de widgets e smoke test (`widget_test.dart`).

Para rodar os testes:
```bash
flutter test
```

Para analisar a saúde e padrão de código:
```bash
dart analyze
```

---

## 💻 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK (3.x ou superior)
- Dart SDK (3.x ou superior)
- Dispositivo Android físico/emulador, Windows Desktop ou Google Chrome

### Passos
1. Clone o repositório:
```bash
git clone https://github.com/MatheusPS-Dev/Arvo.git
cd Arvo
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute no seu dispositivo de preferência:
```bash
# Para rodar no celular Android conectado:
flutter run

# Para rodar no Navegador Web (Chrome):
flutter run -d chrome

# Para rodar no Windows Desktop:
flutter run -d windows
```

---

*Desenvolvido com excelência técnica para o Desafio Agronomia — Arvô.*
