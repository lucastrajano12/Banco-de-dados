-- ============================================================
-- BANCO DE DADOS II — DESAFIO FINAL DO SEMESTRE
-- EMPRESA: SPORTZONE
-- Relatório Gerencial Executivo
--
-- Este arquivo assume que o schema e os dados já foram criados
-- a partir de DDL_desafio_final.sql (tabelas clientes, vendedores,
-- produtos, vendas e itens_venda).
--
-- Observação importante sobre correções:
-- As consultas originais da Parte 1, Parte 2 e Parte 3, além do
-- KPI 03 e do KPI 04, foram REESCRITAS nesta versão. As versões
-- anteriores somavam o faturamento por venda (CTE agregada por
-- id_venda) ao mesmo tempo em que faziam JOIN direto com
-- itens_venda na mesma consulta. Isso gerava um "fan-out": cada
-- linha de item de venda duplicava o valor já agregado da venda,
-- inflando faturamento e contagens (ex.: o vendedor Carlos Mendes
-- aparecia com R$ 29.011,80 quando o valor real é R$ 11.856,60).
-- A correção abaixo agrega em uma única etapa por venda (ou
-- calcula direto por produto, sem re-somar o total da venda),
-- evitando a duplicação.
-- ============================================================


-- ============================================================
-- PARTE 1 — Análise de Clientes
-- Objetivo:
-- Apresentar, para cada cliente, quantidade de compras, produtos
-- adquiridos, valor total gasto, ticket médio e data da última
-- compra — incluindo clientes que nunca compraram.
-- ============================================================
WITH valor_por_venda AS (
    SELECT
        v.id_venda,
        v.id_cliente,
        v.data_venda,
        COALESCE(SUM(iv.quantidade), 0) AS quantidade_itens,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS valor_venda
    FROM vendas AS v
    LEFT JOIN itens_venda AS iv
        ON v.id_venda = iv.id_venda
    GROUP BY v.id_venda, v.id_cliente, v.data_venda
)
SELECT
    c.id_cliente,
    c.nome,
    c.cidade,
    c.renda,
    COUNT(vv.id_venda) AS quantidade_compras,
    COALESCE(SUM(vv.quantidade_itens), 0) AS quantidade_produtos_adquiridos,
    COALESCE(SUM(vv.valor_venda), 0) AS valor_total_gasto,
    COALESCE(ROUND(SUM(vv.valor_venda) / NULLIF(COUNT(vv.id_venda), 0), 2), 0) AS ticket_medio,
    MAX(vv.data_venda) AS data_ultima_compra
FROM clientes AS c
LEFT JOIN valor_por_venda AS vv
    ON c.id_cliente = vv.id_cliente
GROUP BY c.id_cliente, c.nome, c.cidade, c.renda
ORDER BY valor_total_gasto DESC;


-- ============================================================
-- PARTE 2 — Análise de Produtos
-- Objetivo:
-- Apresentar, para cada produto, preço, estoque, quantidade
-- vendida, faturamento gerado e número de clientes diferentes
-- que compraram — incluindo produtos nunca vendidos.
-- ============================================================
SELECT
    p.id_produto,
    p.nome,
    p.preco,
    p.estoque,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida,
    COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento,
    COUNT(DISTINCT v.id_cliente) AS clientes_distintos
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON iv.id_produto = p.id_produto
LEFT JOIN vendas AS v
    ON v.id_venda = iv.id_venda
GROUP BY p.id_produto, p.nome, p.preco, p.estoque
ORDER BY quantidade_vendida DESC;


-- ============================================================
-- PARTE 3 — Análise de Vendedores
-- Objetivo:
-- Apresentar, para cada vendedor, quantidade de vendas, clientes
-- distintos atendidos, produtos vendidos, faturamento total e
-- ticket médio — incluindo vendedores sem vendas.
-- ============================================================
WITH valor_por_venda AS (
    SELECT
        v.id_venda,
        v.id_vendedor,
        v.id_cliente,
        COALESCE(SUM(iv.quantidade), 0) AS quantidade_itens,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS valor_venda
    FROM vendas AS v
    LEFT JOIN itens_venda AS iv
        ON v.id_venda = iv.id_venda
    GROUP BY v.id_venda, v.id_vendedor, v.id_cliente
)
SELECT
    ve.id_vendedor,
    ve.nome,
    COUNT(vv.id_venda) AS quantidade_vendas,
    COUNT(DISTINCT vv.id_cliente) AS clientes_distintos_atendidos,
    COALESCE(SUM(vv.quantidade_itens), 0) AS quantidade_produtos_vendidos,
    COALESCE(SUM(vv.valor_venda), 0) AS faturamento_total,
    COALESCE(ROUND(SUM(vv.valor_venda) / NULLIF(COUNT(vv.id_venda), 0), 2), 0) AS ticket_medio
FROM vendedores AS ve
LEFT JOIN valor_por_venda AS vv
    ON ve.id_vendedor = vv.id_vendedor
GROUP BY ve.id_vendedor, ve.nome
ORDER BY faturamento_total DESC;


-- ============================================================
-- PARTE 4 — KPIs Gerenciais Obrigatórios
-- ============================================================

-- ------------------------------------------------------------
-- KPI 01 — Qual cliente mais gastou na SportZone?
-- ------------------------------------------------------------
WITH total_gasto AS (
    SELECT
        id_venda,
        COALESCE(SUM(quantidade * preco_unitario), 0) AS total_gasto
    FROM itens_venda
    GROUP BY id_venda
)
SELECT
    c.id_cliente,
    c.nome,
    c.cidade,
    COALESCE(SUM(tg.total_gasto), 0) AS total_gasto
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
LEFT JOIN total_gasto AS tg
    ON tg.id_venda = v.id_venda
GROUP BY c.id_cliente, c.nome, c.cidade
ORDER BY total_gasto DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 02 — Qual cliente realizou a maior quantidade de compras?
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome,
    c.cidade,
    COUNT(DISTINCT v.id_venda) AS quantidade_compras
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome, c.cidade
ORDER BY quantidade_compras DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 03 — Qual produto teve a maior quantidade de unidades vendidas?
-- Observação: corrigido para somar iv.quantidade (unidades reais),
-- em vez de contar linhas de item de venda.
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON iv.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY quantidade_vendida DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 04 — Qual produto gerou o maior faturamento?
-- Observação: corrigido — antes o faturamento vinha de uma CTE
-- por venda, o que atribuía a um produto o faturamento da venda
-- inteira (incluindo outros produtos da mesma compra).
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome,
    COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON iv.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY faturamento DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 05 — Quais produtos nunca foram vendidos?
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON iv.id_produto = p.id_produto
WHERE iv.id_produto IS NULL;


-- ------------------------------------------------------------
-- KPI 06 — Qual vendedor realizou a maior quantidade de vendas?
-- ------------------------------------------------------------
SELECT
    ve.id_vendedor,
    ve.nome,
    COUNT(v.id_vendedor) AS quantidade_vendas
FROM vendedores AS ve
LEFT JOIN vendas AS v
    ON v.id_vendedor = ve.id_vendedor
GROUP BY ve.id_vendedor, ve.nome
ORDER BY quantidade_vendas DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 07 — Qual vendedor gerou o maior faturamento?
-- ------------------------------------------------------------
WITH faturamento AS (
    SELECT
        id_venda,
        COALESCE(SUM(quantidade * preco_unitario), 0) AS faturamento
    FROM itens_venda
    GROUP BY id_venda
)
SELECT
    ve.id_vendedor,
    ve.nome,
    COALESCE(SUM(f.faturamento), 0) AS faturamento_total
FROM vendedores AS ve
LEFT JOIN vendas AS v
    ON v.id_vendedor = ve.id_vendedor
LEFT JOIN faturamento AS f
    ON f.id_venda = v.id_venda
GROUP BY ve.id_vendedor, ve.nome
ORDER BY faturamento_total DESC
LIMIT 1;


-- ------------------------------------------------------------
-- KPI 08 — Quantos clientes nunca realizaram uma compra?
-- ------------------------------------------------------------
SELECT
    COUNT(DISTINCT c.id_cliente) AS clientes_sem_compra
FROM clientes AS c
LEFT JOIN vendas AS v
    ON v.id_cliente = c.id_cliente
WHERE v.id_cliente IS NULL;


-- ------------------------------------------------------------
-- KPI 09 — Qual foi o faturamento total da empresa?
-- ------------------------------------------------------------
SELECT
    COALESCE(SUM(quantidade * preco_unitario), 0) AS faturamento_total
FROM itens_venda;


-- ------------------------------------------------------------
-- KPI 10 — Qual é o ticket médio geral das vendas?
-- ------------------------------------------------------------
WITH faturamento AS (
    SELECT
        id_venda,
        COALESCE(SUM(quantidade * preco_unitario), 0) AS faturamento
    FROM itens_venda
    GROUP BY id_venda
)
SELECT
    COALESCE(ROUND(SUM(f.faturamento) / NULLIF(COUNT(DISTINCT v.id_venda), 0), 2), 0) AS ticket_medio
FROM vendas AS v
LEFT JOIN faturamento AS f
    ON f.id_venda = v.id_venda;


-- ============================================================
-- PARTE 5 — KPIs Criados pela Dupla
-- ============================================================

-- ------------------------------------------------------------
-- KPI 11 — Concentração de Faturamento (Top 4 clientes)
-- Objetivo:
-- Medir o quanto os clientes de maior valor concentram do
-- faturamento total, indicando dependência (ou não) de poucos
-- clientes-chave.
-- ------------------------------------------------------------
WITH faturamento_cliente AS (
    SELECT
        c.id_cliente,
        c.nome,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento_cliente
    FROM clientes AS c
    LEFT JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
    LEFT JOIN itens_venda AS iv
        ON v.id_venda = iv.id_venda
    GROUP BY c.id_cliente, c.nome
),
total_geral AS (
    SELECT SUM(faturamento_cliente) AS faturamento_total
    FROM faturamento_cliente
),
top_clientes AS (
    SELECT
        nome,
        faturamento_cliente
    FROM faturamento_cliente
    ORDER BY faturamento_cliente DESC
    LIMIT 4
)
SELECT
    (SELECT SUM(faturamento_cliente) FROM top_clientes) AS faturamento_top_4_clientes,
    tg.faturamento_total,
    ROUND((SELECT SUM(faturamento_cliente) FROM top_clientes) / NULLIF(tg.faturamento_total, 0) * 100, 2) AS percentual_concentracao
FROM total_geral AS tg;


-- ------------------------------------------------------------
-- KPI 12 — Índice de Giro de Estoque por Produto (menor giro)
-- Objetivo:
-- Identificar produtos com maior volume de estoque parado em
-- relação ao que já venderam, sinalizando risco de capital
-- imobilizado.
-- ------------------------------------------------------------
WITH vendas_produto AS (
    SELECT
        p.id_produto,
        p.nome,
        p.estoque,
        COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida
    FROM produtos AS p
    LEFT JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
    GROUP BY p.id_produto, p.nome, p.estoque
)
SELECT
    id_produto,
    nome,
    estoque,
    quantidade_vendida,
    ROUND(quantidade_vendida * 1.0 / estoque, 2) AS indice_giro
FROM vendas_produto
WHERE quantidade_vendida > 0
ORDER BY indice_giro ASC
LIMIT 5;


-- ------------------------------------------------------------
-- KPI 13 — Cidades com Maior Número de Clientes Ativos
-- Objetivo:
-- Identificar em quais cidades a SportZone tem mais clientes
-- que já compraram, para apoiar decisões de expansão e logística.
-- ------------------------------------------------------------
SELECT
    c.cidade,
    COUNT(DISTINCT c.id_cliente) AS clientes_ativos
FROM clientes AS c
WHERE EXISTS (
    SELECT 1
    FROM vendas AS v
    WHERE v.id_cliente = c.id_cliente
)
GROUP BY c.cidade
HAVING COUNT(DISTINCT c.id_cliente) >= 1
ORDER BY clientes_ativos DESC;


-- ------------------------------------------------------------
-- KPI 14 — Clientes Recorrentes (3 ou mais compras)
-- Objetivo:
-- Identificar clientes fiéis, que já compraram 3 vezes ou mais,
-- para ações de relacionamento e programas de fidelidade.
-- ------------------------------------------------------------
WITH compras_por_cliente AS (
    SELECT
        c.id_cliente,
        c.nome,
        COUNT(v.id_venda) AS quantidade_compras
    FROM clientes AS c
    INNER JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome
)
SELECT
    id_cliente,
    nome,
    quantidade_compras
FROM compras_por_cliente
WHERE quantidade_compras >= 3
ORDER BY quantidade_compras DESC;


-- ------------------------------------------------------------
-- KPI 15 — Evolução das Vendas ao Longo do Tempo (faturamento mensal)
-- Objetivo:
-- Acompanhar a evolução mês a mês do faturamento e da quantidade
-- de vendas, apoiando a diretoria a identificar tendências de
-- crescimento e sazonalidade.
-- ------------------------------------------------------------
SELECT
    DATE_FORMAT(v.data_venda, '%Y-%m') AS mes_referencia,
    COUNT(DISTINCT v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento_mensal
FROM vendas AS v
LEFT JOIN itens_venda AS iv
    ON v.id_venda = iv.id_venda
GROUP BY mes_referencia
ORDER BY mes_referencia;

-- Observação de compatibilidade: DATE_FORMAT é sintaxe do MySQL.
-- Em PostgreSQL, o equivalente seria TO_CHAR(v.data_venda, 'YYYY-MM').
