-- ============================================================
-- PROJETO DIO: BANCO DE DADOS DE OFICINA MECANICA
-- SGBD: MySQL 8.0+
-- Arquivo: oficina_mecanica.sql
-- ============================================================
-- Este script cria o schema, as tabelas, dados de teste e consultas.
-- ATENCAO: DROP DATABASE apaga a base oficina_mecanica existente.
-- Para preservar uma base existente, comente a linha DROP DATABASE.
-- ============================================================

DROP DATABASE IF EXISTS oficina_mecanica;

CREATE DATABASE oficina_mecanica
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE oficina_mecanica;

-- ============================================================
-- 1. TABELAS PRINCIPAIS
-- ============================================================

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    nif CHAR(9) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    endereco VARCHAR(200),
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    matricula VARCHAR(12) NOT NULL UNIQUE,
    marca VARCHAR(60) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    ano_fabrico YEAR,
    vin VARCHAR(17) UNIQUE,
    quilometragem INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_veiculo_quilometragem CHECK (quilometragem >= 0),
    CONSTRAINT fk_veiculo_cliente
      FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    nif CHAR(9) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    especialidade VARCHAR(100),
    data_admissao DATE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE equipe_mecanicos (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE equipe_mecanico (
    id_equipe INT NOT NULL,
    id_mecanico INT NOT NULL,
    data_entrada DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (id_equipe, id_mecanico),
    CONSTRAINT fk_em_equipe FOREIGN KEY (id_equipe)
      REFERENCES equipe_mecanicos(id_equipe)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_em_mecanico FOREIGN KEY (id_mecanico)
      REFERENCES mecanico(id_mecanico)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    preco_base DECIMAL(10,2) NOT NULL,
    tempo_estimado_min INT NOT NULL DEFAULT 60,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_servico_preco CHECK (preco_base >= 0),
    CONSTRAINT chk_servico_tempo CHECK (tempo_estimado_min > 0)
) ENGINE=InnoDB;

CREATE TABLE peca (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    referencia VARCHAR(40) NOT NULL UNIQUE,
    nome VARCHAR(120) NOT NULL,
    fabricante VARCHAR(100),
    preco_unitario DECIMAL(10,2) NOT NULL,
    quantidade_stock INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_peca_preco CHECK (preco_unitario >= 0),
    CONSTRAINT chk_peca_stock CHECK (quantidade_stock >= 0),
    CONSTRAINT chk_peca_stock_minimo CHECK (stock_minimo >= 0)
) ENGINE=InnoDB;

-- ============================================================
-- 2. ORDEM DE SERVICO E TABELAS ASSOCIATIVAS
-- ============================================================

CREATE TABLE ordem_servico (
    id_ordem INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    id_mecanico_responsavel INT NOT NULL,
    data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_previsao DATE,
    data_conclusao DATETIME,
    estado ENUM('Aberta','Em diagnostico','Aguardando aprovacao',
                'Em execucao','Concluida','Entregue','Cancelada')
           NOT NULL DEFAULT 'Aberta',
    descricao_problema TEXT NOT NULL,
    observacoes TEXT,
    CONSTRAINT chk_os_datas CHECK (
      data_conclusao IS NULL OR data_conclusao >= data_abertura
    ),
    CONSTRAINT fk_os_veiculo FOREIGN KEY (id_veiculo)
      REFERENCES veiculo(id_veiculo)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_equipe FOREIGN KEY (id_equipe)
      REFERENCES equipe_mecanicos(id_equipe)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_mecanico FOREIGN KEY (id_mecanico_responsavel)
      REFERENCES mecanico(id_mecanico)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE mao_obra_os (
    id_ordem INT NOT NULL,
    id_servico INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_ordem, id_servico),
    CONSTRAINT chk_mao_obra_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_mao_obra_preco CHECK (preco_unitario >= 0),
    CONSTRAINT fk_mo_ordem FOREIGN KEY (id_ordem)
      REFERENCES ordem_servico(id_ordem)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_mo_servico FOREIGN KEY (id_servico)
      REFERENCES servico(id_servico)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE peca_os (
    id_ordem INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_ordem, id_peca),
    CONSTRAINT chk_peca_os_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_peca_os_preco CHECK (preco_unitario >= 0),
    CONSTRAINT fk_po_ordem FOREIGN KEY (id_ordem)
      REFERENCES ordem_servico(id_ordem)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_po_peca FOREIGN KEY (id_peca)
      REFERENCES peca(id_peca)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento ENUM('Cartao','MB Way','Dinheiro','Transferencia','Multibanco')
                    NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    estado ENUM('Pendente','Pago','Reembolsado','Falhado') NOT NULL DEFAULT 'Pendente',
    referencia VARCHAR(100),
    CONSTRAINT chk_pagamento_valor CHECK (valor > 0),
    CONSTRAINT fk_pagamento_ordem FOREIGN KEY (id_ordem)
      REFERENCES ordem_servico(id_ordem)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- 3. DADOS DE TESTE
-- ============================================================

INSERT INTO cliente (nome, nif, telefone, email, endereco) VALUES
('Ana Martins', '245681903', '+351912345601', 'ana.martins@example.com', 'Braga'),
('Bruno Costa', '198765432', '+351912345602', 'bruno.costa@example.com', 'Guimaraes'),
('Carla Ferreira', '276543819', '+351912345603', 'carla.ferreira@example.com', 'Vila Verde'),
('Daniel Sousa', '231456789', '+351912345604', 'daniel.sousa@example.com', 'Braga'),
('Eva Ribeiro', '289123456', '+351912345605', 'eva.ribeiro@example.com', 'Barcelos');

INSERT INTO veiculo
(id_cliente, matricula, marca, modelo, ano_fabrico, vin, quilometragem) VALUES
(1, '12-AB-34', 'Renault', 'Clio', 2018, 'VF1RJA00012345678', 78500),
(1, '45-CD-67', 'Peugeot', '308', 2020, 'VF3LBB00023456789', 52300),
(2, '23-EF-45', 'Volkswagen', 'Golf', 2017, 'WVWZZZ1KZHW123456', 112000),
(3, '67-GH-89', 'Toyota', 'Yaris', 2021, 'VNKKD3D300A123456', 34800),
(4, '89-IJ-01', 'BMW', '320d', 2016, 'WBA8E11070K123456', 145000),
(5, '10-KL-23', 'Ford', 'Focus', 2019, 'WF0NXXGCHNKA12345', 69000);

INSERT INTO mecanico (nome, nif, telefone, email, especialidade, data_admissao, ativo) VALUES
('Rui Almeida', '201234567', '+351913000001', 'rui.almeida@oficina.example', 'Diagnostico', '2021-04-12', TRUE),
('Sofia Mendes', '202345678', '+351913000002', 'sofia.mendes@oficina.example', 'Mecanica geral', '2022-06-01', TRUE),
('Tiago Lopes', '203456789', '+351913000003', 'tiago.lopes@oficina.example', 'Travagem', '2020-09-15', TRUE),
('Ines Carvalho', '204567891', '+351913000004', 'ines.carvalho@oficina.example', 'Eletricidade auto', '2023-02-20', TRUE);

INSERT INTO equipe_mecanicos (nome, descricao) VALUES
('Equipa Alfa', 'Diagnostico e manutencao geral'),
('Equipa Beta', 'Travagem e mecanica'),
('Equipa Gama', 'Eletricidade e diagnostico');

INSERT INTO equipe_mecanico (id_equipe, id_mecanico, data_entrada) VALUES
(1, 1, '2021-04-12'),
(1, 2, '2022-06-01'),
(2, 2, '2022-06-01'),
(2, 3, '2020-09-15'),
(3, 1, '2021-04-12'),
(3, 4, '2023-02-20');

INSERT INTO servico (nome, descricao, preco_base, tempo_estimado_min) VALUES
('Mudanca de oleo', 'Substituicao de oleo e verificacao basica', 65.00, 45),
('Revisao geral', 'Inspecao preventiva do veiculo', 120.00, 120),
('Substituicao de pastilhas', 'Substituicao de pastilhas de travoes', 85.00, 90),
('Diagnostico eletronico', 'Leitura e analise de codigos de avaria', 45.00, 40),
('Substituicao de bateria', 'Remocao e instalacao de bateria', 35.00, 30),
('Alinhamento de direcao', 'Alinhamento das rodas dianteiras', 40.00, 45);

INSERT INTO peca (referencia, nome, fabricante, preco_unitario, quantidade_stock, stock_minimo) VALUES
('OLEO-5W30', 'Oleo motor 5W30 (litro)', 'TotalEnergies', 12.50, 40, 10),
('FILTRO-OLEO-01', 'Filtro de oleo', 'Bosch', 9.90, 18, 5),
('PASTILHA-FRT-01', 'Jogo de pastilhas dianteiras', 'ATE', 48.00, 8, 3),
('BATERIA-60AH', 'Bateria 60Ah', 'Varta', 92.00, 4, 2),
('FILTRO-AR-01', 'Filtro de ar', 'Mann', 16.50, 2, 4),
('LAMPADA-H7', 'Lampada H7', 'Philips', 8.00, 15, 5);

INSERT INTO ordem_servico
(id_veiculo, id_equipe, id_mecanico_responsavel, data_abertura, data_previsao,
 data_conclusao, estado, descricao_problema, observacoes) VALUES
(1, 1, 1, '2026-10-01 09:00:00', '2026-10-02', '2026-10-02 15:30:00', 'Entregue',
 'Revisao periodica e mudanca de oleo', 'Veiculo entregue ao cliente.'),
(3, 2, 3, '2026-10-04 10:15:00', '2026-10-06', NULL, 'Em execucao',
 'Ruido ao travar', 'Aguardar verificacao final.'),
(2, 1, 2, '2026-10-10 08:30:00', '2026-10-11', NULL, 'Aguardando aprovacao',
 'Luz de avaria acesa no painel', 'Orcamento enviado ao cliente.'),
(4, 3, 4, '2026-10-12 11:00:00', '2026-10-12', '2026-10-12 16:00:00', 'Entregue',
 'Problema de bateria e arranque', 'Bateria substituida.'),
(5, 2, 3, '2026-10-15 14:00:00', '2026-10-17', NULL, 'Aberta',
 'Revisao dos travoes', 'Aguardando diagnostico inicial.'),
(6, 1, 1, '2026-10-20 09:20:00', '2026-10-21', NULL, 'Em diagnostico',
 'Consumo de combustivel elevado', 'Realizar diagnostico e revisao.');

INSERT INTO mao_obra_os (id_ordem, id_servico, quantidade, preco_unitario) VALUES
(1, 1, 1, 65.00),
(1, 2, 1, 120.00),
(2, 3, 1, 85.00),
(2, 2, 1, 120.00),
(3, 4, 1, 45.00),
(4, 5, 1, 35.00),
(4, 4, 1, 45.00),
(5, 3, 1, 85.00),
(6, 2, 1, 120.00),
(6, 6, 1, 40.00);

INSERT INTO peca_os (id_ordem, id_peca, quantidade, preco_unitario) VALUES
(1, 1, 4, 12.50),
(1, 2, 1, 9.90),
(2, 3, 1, 48.00),
(3, 2, 1, 9.90),
(4, 4, 1, 92.00),
(5, 3, 1, 48.00),
(6, 5, 1, 16.50),
(6, 6, 2, 8.00);

INSERT INTO pagamento (id_ordem, data_pagamento, forma_pagamento, valor, estado, referencia) VALUES
(1, '2026-10-02 15:00:00', 'Cartao', 244.90, 'Pago', 'PAG-OS-001'),
(1, '2026-10-02 15:05:00', 'MB Way', 35.00, 'Pago', 'PAG-OS-001-B'),
(2, '2026-10-05 12:00:00', 'Transferencia', 100.00, 'Pago', 'PAG-OS-002-A'),
(3, '2026-10-10 10:00:00', 'Multibanco', 54.90, 'Pendente', 'PAG-OS-003'),
(4, '2026-10-12 15:45:00', 'Cartao', 172.00, 'Pago', 'PAG-OS-004');

-- ============================================================
-- 4. CONSULTAS DE NEGOCIO
-- Execute individualmente para visualizar cada resultado.
-- ============================================================

-- Q1. Quais sao os clientes registados? (SELECT + ORDER BY)
SELECT id_cliente, nome, nif, telefone, email
FROM cliente
ORDER BY nome;

-- Q2. Quais ordens estao abertas, em diagnostico ou em execucao? (WHERE)
SELECT id_ordem, estado, data_abertura, descricao_problema
FROM ordem_servico
WHERE estado IN ('Aberta', 'Em diagnostico', 'Em execucao')
ORDER BY data_abertura;

-- Q3. Qual e o custo de mao de obra, pecas e total por ordem?
-- Agregacoes separadas evitam duplicacao de valores ao juntar varias tabelas.
SELECT
    os.id_ordem,
    c.nome AS cliente,
    v.matricula,
    COALESCE(mo.total_mao_obra, 0.00) AS total_mao_obra,
    COALESCE(po.total_pecas, 0.00) AS total_pecas,
    COALESCE(mo.total_mao_obra, 0.00) + COALESCE(po.total_pecas, 0.00) AS total_estimado
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_mao_obra
    FROM mao_obra_os
    GROUP BY id_ordem
) mo ON mo.id_ordem = os.id_ordem
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_pecas
    FROM peca_os
    GROUP BY id_ordem
) po ON po.id_ordem = os.id_ordem
ORDER BY total_estimado DESC;

-- Q4. Quais clientes possuem mais de uma ordem de servico? (GROUP BY + HAVING)
SELECT c.id_cliente, c.nome, COUNT(os.id_ordem) AS quantidade_ordens
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
GROUP BY c.id_cliente, c.nome
HAVING COUNT(os.id_ordem) > 1
ORDER BY quantidade_ordens DESC, c.nome;

-- Q5. Quais servicos foram mais realizados? (JOIN + GROUP BY + ORDER BY)
SELECT s.id_servico, s.nome,
       SUM(mo.quantidade) AS vezes_realizado,
       SUM(mo.quantidade * mo.preco_unitario) AS faturacao_mao_obra
FROM servico s
JOIN mao_obra_os mo ON mo.id_servico = s.id_servico
JOIN ordem_servico os ON os.id_ordem = mo.id_ordem
WHERE os.estado <> 'Cancelada'
GROUP BY s.id_servico, s.nome
ORDER BY vezes_realizado DESC, faturacao_mao_obra DESC;

-- Q6. Qual e o total pago e quanto permanece por pagar em cada ordem?
-- O total em aberto e calculado sobre os custos registados menos pagamentos pagos.
SELECT
    os.id_ordem,
    c.nome AS cliente,
    COALESCE(custos.total_ordem, 0.00) AS total_ordem,
    COALESCE(pg.total_pago, 0.00) AS total_pago,
    GREATEST(COALESCE(custos.total_ordem, 0.00) - COALESCE(pg.total_pago, 0.00), 0.00) AS saldo_em_aberto
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
LEFT JOIN (
    SELECT x.id_ordem,
           COALESCE(m.total_mao_obra, 0.00) + COALESCE(p.total_pecas, 0.00) AS total_ordem
    FROM ordem_servico x
    LEFT JOIN (
        SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_mao_obra
        FROM mao_obra_os GROUP BY id_ordem
    ) m ON m.id_ordem = x.id_ordem
    LEFT JOIN (
        SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_pecas
        FROM peca_os GROUP BY id_ordem
    ) p ON p.id_ordem = x.id_ordem
) custos ON custos.id_ordem = os.id_ordem
LEFT JOIN (
    SELECT id_ordem, SUM(valor) AS total_pago
    FROM pagamento
    WHERE estado = 'Pago'
    GROUP BY id_ordem
) pg ON pg.id_ordem = os.id_ordem
ORDER BY saldo_em_aberto DESC;

-- Q7. Quais pecas precisam de reposicao? (WHERE + expressao derivada)
SELECT referencia, nome, quantidade_stock, stock_minimo,
       stock_minimo - quantidade_stock AS unidades_ate_ao_minimo
FROM peca
WHERE quantidade_stock <= stock_minimo
ORDER BY unidades_ate_ao_minimo DESC, nome;

-- Q8. Quais equipas e mecanicos estao associados a cada ordem? (JOIN)
SELECT os.id_ordem, eq.nome AS equipa, m.nome AS mecanico_responsavel,
       os.estado, os.data_abertura
FROM ordem_servico os
JOIN equipe_mecanicos eq ON eq.id_equipe = os.id_equipe
JOIN mecanico m ON m.id_mecanico = os.id_mecanico_responsavel
ORDER BY os.data_abertura DESC;

-- Q9. Quantas ordens existem por estado e qual o custo estimado medio?
SELECT os.estado,
       COUNT(*) AS quantidade_ordens,
       ROUND(AVG(COALESCE(mo.total_mao_obra, 0.00) + COALESCE(po.total_pecas, 0.00)), 2) AS custo_medio
FROM ordem_servico os
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_mao_obra
    FROM mao_obra_os GROUP BY id_ordem
) mo ON mo.id_ordem = os.id_ordem
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_pecas
    FROM peca_os GROUP BY id_ordem
) po ON po.id_ordem = os.id_ordem
GROUP BY os.estado
HAVING COUNT(*) >= 1
ORDER BY quantidade_ordens DESC;

-- Q10. Que clientes gastaram mais de 200 euros em ordens de servico?
SELECT c.id_cliente, c.nome,
       SUM(COALESCE(mo.total_mao_obra, 0.00) + COALESCE(po.total_pecas, 0.00)) AS total_gasto
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_mao_obra
    FROM mao_obra_os GROUP BY id_ordem
) mo ON mo.id_ordem = os.id_ordem
LEFT JOIN (
    SELECT id_ordem, SUM(quantidade * preco_unitario) AS total_pecas
    FROM peca_os GROUP BY id_ordem
) po ON po.id_ordem = os.id_ordem
WHERE os.estado <> 'Cancelada'
GROUP BY c.id_cliente, c.nome
HAVING SUM(COALESCE(mo.total_mao_obra, 0.00) + COALESCE(po.total_pecas, 0.00)) > 200
ORDER BY total_gasto DESC;

-- Q11. Qual a distribuicao dos pagamentos por forma de pagamento?
SELECT forma_pagamento, COUNT(*) AS numero_pagamentos,
       SUM(valor) AS valor_registado,
       SUM(CASE WHEN estado = 'Pago' THEN valor ELSE 0 END) AS valor_pago
FROM pagamento
GROUP BY forma_pagamento
ORDER BY valor_registado DESC;

-- Q12. Existem ordens sem servicos associados?
SELECT os.id_ordem, os.estado
FROM ordem_servico os
LEFT JOIN mao_obra_os mo ON mo.id_ordem = os.id_ordem
WHERE mo.id_ordem IS NULL
ORDER BY os.id_ordem;

-- Q13. Quais veiculos pertencem a cada cliente e quantos km tem?
SELECT c.nome AS cliente, v.matricula, v.marca, v.modelo,
       v.quilometragem,
       CASE
         WHEN v.quilometragem >= 150000 THEN 'Quilometragem elevada'
         WHEN v.quilometragem >= 80000 THEN 'Quilometragem moderada'
         ELSE 'Quilometragem inferior'
       END AS faixa_quilometragem
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
ORDER BY v.quilometragem DESC;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
