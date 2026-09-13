-- ============================================================
-- CHALLENGE NIGHT — DASHBOARD EXECUTIVO DA TECHVENDAS S/A
-- 15 KPIs para apoiar decisões estratégicas da diretoria
-- Base: mesmas tabelas da aula 02/03 (exercicios_inner_join_schema.sql)
-- Tabelas: clientes, vendedores, produtos, vendas, itens_venda
--
-- Requisitos obrigatórios utilizados ao longo do arquivo:
-- CTE, INNER JOIN, LEFT JOIN, COUNT, SUM, AVG, MIN, MAX,
-- COUNT(DISTINCT), GROUP BY, ORDER BY.
-- ============================================================


-- ------------------------------------------------------------
-- KPI 01 — Faturamento líquido por categoria de produto
-- ------------------------------------------------------------
SELECT
    p.categoria,
    SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)) AS faturamento_liquido
FROM itens_venda AS iv
INNER JOIN produtos AS p
    ON iv.id_produto = p.id_produto
INNER JOIN vendas AS v
    ON iv.id_venda = v.id_venda
WHERE v.status = 'Concluída'
GROUP BY p.categoria
ORDER BY faturamento_liquido DESC;


-- ------------------------------------------------------------
-- KPI 02 — Ticket médio por vendedor
-- ------------------------------------------------------------
SELECT
    vd.nome_vendedor,
    COUNT(v.id_venda) AS quantidade_vendas,
    AVG(v.valor_total) AS ticket_medio
FROM vendas AS v
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
WHERE v.status = 'Concluída'
GROUP BY vd.id_vendedor, vd.nome_vendedor
ORDER BY ticket_medio DESC;


-- ------------------------------------------------------------
-- KPI 03 — Top 5 clientes por faturamento e participação percentual
-- ------------------------------------------------------------
WITH faturamento_clientes AS (
    SELECT
        c.id_cliente,
        c.nome_cliente,
        SUM(v.valor_total) AS faturamento_cliente
    FROM vendas AS v
    INNER JOIN clientes AS c
        ON v.id_cliente = c.id_cliente
    WHERE v.status = 'Concluída'
    GROUP BY c.id_cliente, c.nome_cliente
),
total_geral AS (
    SELECT SUM(faturamento_cliente) AS faturamento_total
    FROM faturamento_clientes
)
SELECT
    fc.nome_cliente,
    fc.faturamento_cliente,
    ROUND(fc.faturamento_cliente / tg.faturamento_total * 100, 2) AS percentual_do_total
FROM faturamento_clientes AS fc
CROSS JOIN total_geral AS tg
ORDER BY fc.faturamento_cliente DESC
LIMIT 5;


-- ------------------------------------------------------------
-- KPI 04 — Clientes sem nenhuma compra
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.cidade
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venda IS NULL;


-- ------------------------------------------------------------
-- KPI 05 — Vendedores sem vendas registradas
-- ------------------------------------------------------------
SELECT
    vd.id_vendedor,
    vd.nome_vendedor,
    vd.setor
FROM vendedores AS vd
LEFT JOIN vendas AS v
    ON vd.id_vendedor = v.id_vendedor
WHERE v.id_venda IS NULL;


-- ------------------------------------------------------------
-- KPI 06 — Produtos cadastrados nunca vendidos
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.categoria
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
WHERE iv.id_item IS NULL;


-- ------------------------------------------------------------
-- KPI 07 — Diversidade de produtos comprados por cliente
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    COUNT(DISTINCT iv.id_produto) AS produtos_distintos_comprados
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN itens_venda AS iv
    ON v.id_venda = iv.id_venda
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY produtos_distintos_comprados DESC;


-- ------------------------------------------------------------
-- KPI 08 — Quantidade de clientes distintos atendidos por vendedor
-- ------------------------------------------------------------
SELECT
    vd.nome_vendedor,
    COUNT(DISTINCT v.id_cliente) AS clientes_distintos_atendidos
FROM vendas AS v
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
GROUP BY vd.id_vendedor, vd.nome_vendedor
ORDER BY clientes_distintos_atendidos DESC;


-- ------------------------------------------------------------
-- KPI 09 — Faixa de preço por categoria de produto
-- ------------------------------------------------------------
SELECT
    p.categoria,
    MIN(p.preco) AS menor_preco,
    MAX(p.preco) AS maior_preco,
    AVG(p.preco) AS preco_medio
FROM produtos AS p
GROUP BY p.categoria
ORDER BY maior_preco DESC;


-- ------------------------------------------------------------
-- KPI 10 — Desempenho por forma de pagamento
-- ------------------------------------------------------------
SELECT
    v.forma_pagamento,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS faturamento_total,
    AVG(v.valor_total) AS ticket_medio
FROM vendas AS v
WHERE v.status = 'Concluída'
GROUP BY v.forma_pagamento
ORDER BY faturamento_total DESC;


-- ------------------------------------------------------------
-- KPI 11 — Clientes com apenas uma compra
-- ------------------------------------------------------------
WITH compras_por_cliente AS (
    SELECT
        c.id_cliente,
        c.nome_cliente,
        COUNT(v.id_venda) AS quantidade_compras
    FROM clientes AS c
    INNER JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome_cliente
)
SELECT
    id_cliente,
    nome_cliente,
    quantidade_compras
FROM compras_por_cliente
WHERE quantidade_compras = 1
ORDER BY nome_cliente;


-- ------------------------------------------------------------
-- KPI 12 — Participação percentual de cada categoria no faturamento
-- ------------------------------------------------------------
WITH faturamento_categoria AS (
    SELECT
        p.categoria,
        SUM(iv.quantidade * iv.valor_unitario) AS faturamento_categoria
    FROM itens_venda AS iv
    INNER JOIN produtos AS p
        ON iv.id_produto = p.id_produto
    GROUP BY p.categoria
),
total_geral_categorias AS (
    SELECT SUM(faturamento_categoria) AS faturamento_total
    FROM faturamento_categoria
)
SELECT
    fc.categoria,
    fc.faturamento_categoria,
    ROUND(fc.faturamento_categoria / tg.faturamento_total * 100, 2) AS percentual_do_faturamento
FROM faturamento_categoria AS fc
CROSS JOIN total_geral_categorias AS tg
ORDER BY fc.faturamento_categoria DESC;


-- ------------------------------------------------------------
-- KPI 13 — Vendedores com faturamento acima da média da equipe
-- ------------------------------------------------------------
WITH faturamento_vendedor AS (
    SELECT
        vd.id_vendedor,
        vd.nome_vendedor,
        SUM(v.valor_total) AS faturamento_vendedor
    FROM vendas AS v
    INNER JOIN vendedores AS vd
        ON v.id_vendedor = vd.id_vendedor
    WHERE v.status = 'Concluída'
    GROUP BY vd.id_vendedor, vd.nome_vendedor
),
media_vendedores AS (
    SELECT AVG(faturamento_vendedor) AS media_faturamento
    FROM faturamento_vendedor
)
SELECT
    fv.nome_vendedor,
    fv.faturamento_vendedor,
    mv.media_faturamento,
    fv.faturamento_vendedor - mv.media_faturamento AS diferenca_para_media
FROM faturamento_vendedor AS fv
CROSS JOIN media_vendedores AS mv
WHERE fv.faturamento_vendedor > mv.media_faturamento
ORDER BY fv.faturamento_vendedor DESC;


-- ------------------------------------------------------------
-- KPI 14 — Top 3 produtos mais vendidos em quantidade
-- ------------------------------------------------------------
WITH quantidade_por_produto AS (
    SELECT
        p.id_produto,
        p.nome_produto,
        p.categoria,
        SUM(iv.quantidade) AS quantidade_total_vendida
    FROM itens_venda AS iv
    INNER JOIN produtos AS p
        ON iv.id_produto = p.id_produto
    GROUP BY p.id_produto, p.nome_produto, p.categoria
)
SELECT
    nome_produto,
    categoria,
    quantidade_total_vendida
FROM quantidade_por_produto
ORDER BY quantidade_total_vendida DESC
LIMIT 3;


-- ------------------------------------------------------------
-- KPI 15 — Relacionamento com o cliente (recência, frequência e valor)
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    COUNT(v.id_venda) AS quantidade_compras,
    COALESCE(SUM(v.valor_total), 0) AS valor_total_comprado,
    MIN(v.data_venda) AS data_primeira_compra,
    MAX(v.data_venda) AS data_ultima_compra
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY valor_total_comprado DESC;
