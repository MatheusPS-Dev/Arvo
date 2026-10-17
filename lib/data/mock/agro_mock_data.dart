import '../models/product_model.dart';
import '../models/movement_model.dart';
import '../models/batch_model.dart';
import '../models/category_enum.dart';

class AgroMockData {
  AgroMockData._();

  static const String farmName = 'Fazenda Boa Vista';
  static const String harvestSeason = 'Safra 2026/27';

  /// Gera a lista inicial rica e consistente de insumos da fazenda
  static List<ProductModel> getInitialProducts() {
    final now = DateTime.now();

    return [
      // FERTILIZANTES
      ProductModel(
        id: 'prod_ureia_01',
        code: 'FERT-001',
        name: 'Ureia Granulada 46%',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 120.0, // ESTOQUE BAIXO (consumo alto -> ruptura iminente)
        minStock: 300.0,
        averageUnitCost: 172.50,
        location: 'Barracão A - Posição 04',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-UR-992',
            expirationDate: now.add(const Duration(days: 280)),
            initialQuantity: 500.0,
            remainingQuantity: 120.0,
            unitCost: 172.50,
            entryDate: now.subtract(const Duration(days: 45)),
          ),
        ],
        notes: 'Adubação de cobertura milho e soja.',
      ),
      ProductModel(
        id: 'prod_ureia_dup',
        code: 'FERT-001-B',
        name: 'Uréia Agrícola Granulada', // DUPLICIDADE PROPOSITAL
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 45.0,
        minStock: 50.0,
        averageUnitCost: 175.00,
        location: 'Barracão A - Fundo',
        lastUpdated: now.subtract(const Duration(days: 15)),
        batches: [
          BatchModel(
            batchNumber: 'L-UR-910',
            expirationDate: now.add(const Duration(days: 210)),
            initialQuantity: 100.0,
            remainingQuantity: 45.0,
            unitCost: 175.00,
            entryDate: now.subtract(const Duration(days: 60)),
          ),
        ],
        notes: 'Cadastrado separadamente pelo almoxarifado.',
      ),
      ProductModel(
        id: 'prod_npk_041408',
        code: 'FERT-002',
        name: 'NPK 04-14-08',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 850.0,
        minStock: 400.0,
        averageUnitCost: 155.20,
        location: 'Barracão A - Posição 01',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-NPK-881',
            expirationDate: now.add(const Duration(days: 340)),
            initialQuantity: 1000.0,
            remainingQuantity: 850.0,
            unitCost: 186.00, // COMPRA RECENTE COM AUMENTO DE PREÇO
            entryDate: now.subtract(const Duration(days: 8)),
          ),
        ],
      ),
      ProductModel(
        id: 'prod_kcl',
        code: 'FERT-003',
        name: 'Cloreto de Potássio (KCl)',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 620.0,
        minStock: 250.0,
        averageUnitCost: 210.00,
        location: 'Barracão A - Posição 02',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-KCL-104',
            expirationDate: now.add(const Duration(days: 365)),
            initialQuantity: 800.0,
            remainingQuantity: 620.0,
            unitCost: 210.00,
            entryDate: now.subtract(const Duration(days: 30)),
          ),
        ],
      ),

      // CORRETIVOS
      ProductModel(
        id: 'prod_calcario',
        code: 'CORR-001',
        name: 'Calcário Dolomítico',
        category: ProductCategory.corretivos,
        unit: 'ton',
        currentStock: 180.0,
        minStock: 80.0,
        averageUnitCost: 135.00,
        location: 'Pátio Aberto Norte',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-CALC-33',
            expirationDate: now.add(const Duration(days: 700)),
            initialQuantity: 300.0,
            remainingQuantity: 180.0,
            unitCost: 135.00,
            entryDate: now.subtract(const Duration(days: 60)),
          ),
        ],
      ),

      // SEMENTES
      ProductModel(
        id: 'prod_sem_milho',
        code: 'SEM-001',
        name: 'Semente Milho Híbrido VT PRO 3',
        category: ProductCategory.sementes,
        unit: 'sc',
        currentStock: 340.0,
        minStock: 150.0,
        averageUnitCost: 680.00, // Alto valor financeiro
        location: 'Câmara Fria de Sementes',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-MILHO-2026',
            expirationDate: now.add(const Duration(days: 150)),
            initialQuantity: 500.0,
            remainingQuantity: 340.0,
            unitCost: 680.00,
            entryDate: now.subtract(const Duration(days: 25)),
          ),
        ],
      ),
      ProductModel(
        id: 'prod_sem_soja',
        code: 'SEM-002',
        name: 'Semente Soja Intacta 2 Xtend',
        category: ProductCategory.sementes,
        unit: 'sc',
        currentStock: 520.0,
        minStock: 200.0,
        averageUnitCost: 245.00,
        location: 'Câmara Fria de Sementes',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-SOJA-847',
            expirationDate: now.add(const Duration(days: 180)),
            initialQuantity: 800.0,
            remainingQuantity: 520.0,
            unitCost: 245.00,
            entryDate: now.subtract(const Duration(days: 40)),
          ),
        ],
      ),

      // DEFENSIVOS E BIOLÓGICOS
      ProductModel(
        id: 'prod_inoculante',
        code: 'DEF-001',
        name: 'Inoculante Azospirillum Brasilense',
        category: ProductCategory.defensivosEBbiologicos,
        unit: 'dose',
        currentStock: 380.0, // RISCO DE VENCIMENTO EM 22 DIAS COM PERDA
        minStock: 100.0,
        averageUnitCost: 15.00,
        location: 'Armário Climatizado B-2',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-AZOS-049',
            expirationDate: now.add(const Duration(days: 22)), // VENCE EM 22 DIAS!
            initialQuantity: 500.0,
            remainingQuantity: 380.0,
            unitCost: 15.00,
            entryDate: now.subtract(const Duration(days: 68)),
          ),
        ],
      ),
      ProductModel(
        id: 'prod_fungicida_triazol',
        code: 'DEF-002',
        name: 'Fungicida Triazol + Estrobirulina',
        category: ProductCategory.defensivosEBbiologicos,
        unit: 'L',
        currentStock: 210.0,
        minStock: 120.0,
        averageUnitCost: 148.00,
        location: 'Depósito Químico Trancado',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-FUNG-902',
            expirationDate: now.add(const Duration(days: 310)),
            initialQuantity: 500.0,
            remainingQuantity: 210.0,
            unitCost: 148.00,
            entryDate: now.subtract(const Duration(days: 35)),
          ),
        ],
        notes: 'Aceleração repentina de saídas na última semana.',
      ),
      ProductModel(
        id: 'prod_glifosato',
        code: 'DEF-003',
        name: 'Herbicida Glifosato 480 SL',
        category: ProductCategory.defensivosEBbiologicos,
        unit: 'L',
        currentStock: 800.0,
        minStock: 300.0,
        averageUnitCost: 38.50,
        location: 'Depósito Químico Trancado',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-GLIF-77',
            expirationDate: now.add(const Duration(days: 500)),
            initialQuantity: 1200.0,
            remainingQuantity: 800.0,
            unitCost: 38.50,
            entryDate: now.subtract(const Duration(days: 50)),
          ),
        ],
      ),

      // COMBUSTÍVEIS E LUBRIFICANTES
      ProductModel(
        id: 'prod_diesel_s10',
        code: 'COMB-001',
        name: 'Óleo Diesel S10',
        category: ProductCategory.combustiveisELubrificantes,
        unit: 'L',
        currentStock: 4200.0,
        minStock: 2500.0,
        averageUnitCost: 6.25,
        location: 'Tanque Aéreo Principal 01',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-DSL-2026-10',
            expirationDate: now.add(const Duration(days: 120)),
            initialQuantity: 10000.0,
            remainingQuantity: 4200.0,
            unitCost: 6.25,
            entryDate: now.subtract(const Duration(days: 20)),
          ),
        ],
      ),
      ProductModel(
        id: 'prod_oleo_motor_15w40',
        code: 'COMB-002',
        name: 'Óleo Motor 15W40 Mineral',
        category: ProductCategory.combustiveisELubrificantes,
        unit: 'L',
        currentStock: 240.0,
        minStock: 100.0,
        averageUnitCost: 28.00,
        location: 'Oficina Central',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-LUB-154',
            expirationDate: now.add(const Duration(days: 600)),
            initialQuantity: 400.0,
            remainingQuantity: 240.0,
            unitCost: 28.00,
            entryDate: now.subtract(const Duration(days: 45)),
          ),
        ],
      ),

      // PEÇAS E MANUTENÇÃO
      ProductModel(
        id: 'prod_bicos_pulverizacao',
        code: 'PEC-001',
        name: 'Bicos de Pulverização Cerâmica MagnoJet',
        category: ProductCategory.pecasEManutencao,
        unit: 'un',
        currentStock: 85.0,
        minStock: 40.0,
        averageUnitCost: 32.00,
        location: 'Almoxarifado Peças - Gaveta 12',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-BIC-88',
            expirationDate: now.add(const Duration(days: 1200)),
            initialQuantity: 100.0,
            remainingQuantity: 85.0,
            unitCost: 32.00,
            entryDate: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),

      // MATERIAIS DE IRRIGAÇÃO (CAPITAL PARADO CLASSE A)
      ProductModel(
        id: 'prod_motor_valvula_pivo',
        code: 'IRR-001',
        name: 'Motorredutor e Válvulas Pivô Central 03',
        category: ProductCategory.materiaisDeIrrigacao,
        unit: 'conj',
        currentStock: 4.0, // R$ 38.000,00 PARADO HÁ 78 DIAS
        minStock: 1.0,
        averageUnitCost: 9500.00,
        location: 'Galpão de Irrigação Sul',
        lastUpdated: now.subtract(const Duration(days: 78)),
        batches: [
          BatchModel(
            batchNumber: 'L-PIVO-04',
            expirationDate: now.add(const Duration(days: 1500)),
            initialQuantity: 4.0,
            remainingQuantity: 4.0,
            unitCost: 9500.00,
            entryDate: now.subtract(const Duration(days: 78)),
          ),
        ],
        notes: 'Comprado preventivamente mas sem aplicação prevista no cronograma.',
      ),
      ProductModel(
        id: 'prod_tubo_pvc_100',
        code: 'IRR-002',
        name: 'Tubos PVC Defofo 100mm 6m',
        category: ProductCategory.materiaisDeIrrigacao,
        unit: 'barra',
        currentStock: 110.0,
        minStock: 50.0,
        averageUnitCost: 115.00,
        location: 'Pátio de Tubos',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-TUB-012',
            expirationDate: now.add(const Duration(days: 2000)),
            initialQuantity: 150.0,
            remainingQuantity: 110.0,
            unitCost: 115.00,
            entryDate: now.subtract(const Duration(days: 40)),
          ),
        ],
      ),

      // EPI E DIVERSOS
      ProductModel(
        id: 'prod_respirador_p2',
        code: 'EPI-001',
        name: 'Respirador com Filtro Químico P2',
        category: ProductCategory.epiEDiversos,
        unit: 'un',
        currentStock: 32.0,
        minStock: 20.0,
        averageUnitCost: 45.00,
        location: 'Almoxarifado EPIs',
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'L-EPI-77',
            expirationDate: now.add(const Duration(days: 400)),
            initialQuantity: 60.0,
            remainingQuantity: 32.0,
            unitCost: 45.00,
            entryDate: now.subtract(const Duration(days: 30)),
          ),
        ],
      ),
    ];
  }

  /// Gera histórico de movimentações com os cenários do edital
  static List<MovementModel> getInitialMovements() {
    final now = DateTime.now();

    return [
      // MOVIMENTAÇÕES DE UREIA (Alto ritmo de saída recente -> 20 sc/dia)
      MovementModel(
        id: 'mov_ur_01',
        productId: 'prod_ureia_01',
        productName: 'Ureia Granulada 46%',
        type: MovementType.entrada,
        quantity: 500.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 45)),
        unitPrice: 172.50,
        batchNumber: 'L-UR-992',
        expirationDate: now.add(const Duration(days: 280)),
        supplier: 'Fertilizantes Vale Verde',
        responsible: 'Carlos Agrônomo',
      ),
      MovementModel(
        id: 'mov_ur_02',
        productId: 'prod_ureia_01',
        productName: 'Ureia Granulada 46%',
        type: MovementType.saida,
        quantity: 140.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 20)),
        destination: 'Talhão 01 - Soja',
        responsible: 'João Tratorista',
      ),
      MovementModel(
        id: 'mov_ur_03',
        productId: 'prod_ureia_01',
        productName: 'Ureia Granulada 46%',
        type: MovementType.saida,
        quantity: 120.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 12)),
        destination: 'Talhão 04 - Milho',
        responsible: 'Marcos Silva',
      ),
      MovementModel(
        id: 'mov_ur_04',
        productId: 'prod_ureia_01',
        productName: 'Ureia Granulada 46%',
        type: MovementType.saida,
        quantity: 120.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 4)),
        destination: 'Talhão 03 - Milho',
        responsible: 'Marcos Silva',
      ),

      // DIESEL S10 (Com média de 250L e UMA RETIRADA ATÍPICA DE 980L)
      MovementModel(
        id: 'mov_dsl_ent',
        productId: 'prod_diesel_s10',
        productName: 'Óleo Diesel S10',
        type: MovementType.entrada,
        quantity: 10000.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 20)),
        unitPrice: 6.25,
        supplier: 'Distribuidora PetroAgro',
        responsible: 'Carlos Agrônomo',
      ),
      MovementModel(
        id: 'mov_dsl_01',
        productId: 'prod_diesel_s10',
        productName: 'Óleo Diesel S10',
        type: MovementType.saida,
        quantity: 260.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 15)),
        destination: 'Trator Valtra A950',
        responsible: 'Pedro Mecânico',
      ),
      MovementModel(
        id: 'mov_dsl_02',
        productId: 'prod_diesel_s10',
        productName: 'Óleo Diesel S10',
        type: MovementType.saida,
        quantity: 240.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 10)),
        destination: 'Colheitadeira Case 8230',
        responsible: 'Pedro Mecânico',
      ),
      MovementModel(
        id: 'mov_dsl_03',
        productId: 'prod_diesel_s10',
        productName: 'Óleo Diesel S10',
        type: MovementType.saida,
        quantity: 280.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 6)),
        destination: 'Trator John Deere 6115J',
        responsible: 'Pedro Mecânico',
      ),
      MovementModel(
        id: 'mov_dsl_outlier',
        productId: 'prod_diesel_s10',
        productName: 'Óleo Diesel S10',
        type: MovementType.saida,
        quantity: 980.0, // RETIRADA FORA DO PADRÃO (3.7x superior à média)
        unit: 'L',
        date: now.subtract(const Duration(days: 2)),
        destination: 'Trator John Deere 8R - Talhão 02',
        responsible: 'Lucas Ferreira',
        notes: 'Retirada muito acima do tanque padrão do equipamento.',
      ),

      // INOCULANTE (Consumo lento de 5 doses/dia com 380 doses remanescentes e 22 dias para vencer!)
      MovementModel(
        id: 'mov_inoc_01',
        productId: 'prod_inoculante',
        productName: 'Inoculante Azospirillum Brasilense',
        type: MovementType.entrada,
        quantity: 500.0,
        unit: 'dose',
        date: now.subtract(const Duration(days: 68)),
        unitPrice: 15.00,
        batchNumber: 'L-AZOS-049',
        expirationDate: now.add(const Duration(days: 22)),
        supplier: 'Biotec Agrícola',
        responsible: 'Carlos Agrônomo',
      ),
      MovementModel(
        id: 'mov_inoc_02',
        productId: 'prod_inoculante',
        productName: 'Inoculante Azospirillum Brasilense',
        type: MovementType.saida,
        quantity: 60.0,
        unit: 'dose',
        date: now.subtract(const Duration(days: 40)),
        destination: 'Tratamento de Sementes Soja',
        responsible: 'Ana Bióloga',
      ),
      MovementModel(
        id: 'mov_inoc_03',
        productId: 'prod_inoculante',
        productName: 'Inoculante Azospirillum Brasilense',
        type: MovementType.saida,
        quantity: 60.0,
        unit: 'dose',
        date: now.subtract(const Duration(days: 15)),
        destination: 'Tratamento de Sementes Milho',
        responsible: 'Ana Bióloga',
      ),

      // FUNGICIDA (Aceleração de consumo nos últimos 7 dias)
      MovementModel(
        id: 'mov_fung_01',
        productId: 'prod_fungicida_triazol',
        productName: 'Fungicida Triazol + Estrobirulina',
        type: MovementType.saida,
        quantity: 40.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 25)),
        destination: 'Talhão 01',
        responsible: 'Lucas Ferreira',
      ),
      MovementModel(
        id: 'mov_fung_02',
        productId: 'prod_fungicida_triazol',
        productName: 'Fungicida Triazol + Estrobirulina',
        type: MovementType.saida,
        quantity: 50.0,
        unit: 'L',
        date: now.subtract(const Duration(days: 18)),
        destination: 'Talhão 02',
        responsible: 'Lucas Ferreira',
      ),
      MovementModel(
        id: 'mov_fung_03',
        productId: 'prod_fungicida_triazol',
        productName: 'Fungicida Triazol + Estrobirulina',
        type: MovementType.saida,
        quantity: 100.0, // ACELERAÇÃO RECENTE
        unit: 'L',
        date: now.subtract(const Duration(days: 4)),
        destination: 'Talhão 04 - Pulverizador Autopropelido',
        responsible: 'Lucas Ferreira',
      ),
      MovementModel(
        id: 'mov_fung_04',
        productId: 'prod_fungicida_triazol',
        productName: 'Fungicida Triazol + Estrobirulina',
        type: MovementType.saida,
        quantity: 100.0, // ACELERAÇÃO RECENTE
        unit: 'L',
        date: now.subtract(const Duration(days: 2)),
        destination: 'Talhão 05 - Pulverizador Autopropelido',
        responsible: 'Lucas Ferreira',
      ),

      // NPK 04-14-08 (Duas entradas com variação de preço +28%)
      MovementModel(
        id: 'mov_npk_antiga',
        productId: 'prod_npk_041408',
        productName: 'NPK 04-14-08',
        type: MovementType.entrada,
        quantity: 500.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 90)),
        unitPrice: 145.00, // Preço anterior
        supplier: 'Adubos do Cerrado',
        responsible: 'Carlos Agrônomo',
      ),
      MovementModel(
        id: 'mov_npk_recente',
        productId: 'prod_npk_041408',
        productName: 'NPK 04-14-08',
        type: MovementType.entrada,
        quantity: 500.0,
        unit: 'sc',
        date: now.subtract(const Duration(days: 8)),
        unitPrice: 186.00, // Preço com aumento de +28,3%!
        supplier: 'NutriSolo Agro',
        responsible: 'Carlos Agrônomo',
      ),

      // MOTORREDUTOR PIVÔ (Única entrada há 78 dias, zero saídas)
      MovementModel(
        id: 'mov_pivo_in',
        productId: 'prod_motor_valvula_pivo',
        productName: 'Motorredutor e Válvulas Pivô Central 03',
        type: MovementType.entrada,
        quantity: 4.0,
        unit: 'conj',
        date: now.subtract(const Duration(days: 78)),
        unitPrice: 9500.00,
        supplier: 'Valley Irrigação Peças',
        responsible: 'Pedro Mecânico',
      ),
    ];
  }
}
