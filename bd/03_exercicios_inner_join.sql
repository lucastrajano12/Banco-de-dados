-- ============================================================
-- EXERCÍCIOS DE FIXAÇÃO - INNER JOIN
-- Cenário: TechVendas S/A
-- Base: exercicios_inner_join.sql
-- Tabelas: clientes, vendedores, produtos, vendas, itens_venda
--
-- Regras seguidas:
-- 1. INNER JOIN explícito em todas as questões.
-- 2. Aliases para as tabelas.
-- 3. Sem SELECT *.
-- 4. Código indentado e organizado.
-- ============================================================


-- ------------------------------------------------------------
-- EXERCÍCIO 01 - Clientes que compraram
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    v.valor_total
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 02 - Vendedor responsável
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    vd.nome_vendedor,
    vd.setor,
    v.valor_total
FROM vendas AS v
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
ORDER BY v.data_venda DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 03 - Produtos presentes nas vendas
-- ------------------------------------------------------------
SELECT
    iv.id_item,
    p.nome_produto,
    p.categoria,
    iv.quantidade,
    iv.valor_unitario
FROM itens_venda AS iv
INNER JOIN produtos AS p
    ON iv.id_produto = p.id_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 04 - Detalhamento da venda
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario
FROM vendas AS v
INNER JOIN itens_venda AS iv
    ON v.id_venda = iv.id_venda
INNER JOIN produtos AS p
    ON iv.id_produto = p.id_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 05 - Relatório completo
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vd.nome_vendedor,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
INNER JOIN itens_venda AS iv
    ON v.id_venda = iv.id_venda
INNER JOIN produtos AS p
    ON iv.id_produto = p.id_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 06 - Clientes de Curitiba
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    v.id_venda,
    v.data_venda,
    v.status,
    v.valor_total
FROM clientes AS c
INNER JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
WHERE c.cidade = 'Curitiba';


-- ------------------------------------------------------------
-- EXERCÍCIO 07 - Produtos de Informática vendidos
-- ------------------------------------------------------------
SELECT
    p.nome_produto,
    p.categoria,
    v.id_venda,
    v.data_venda,
    iv.quantidade
FROM produtos AS p
INNER JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
INNER JOIN vendas AS v
    ON iv.id_venda = v.id_venda
WHERE p.categoria = 'Informática';


-- ------------------------------------------------------------
-- EXERCÍCIO 08 - Vendas pagas via Pix
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vd.nome_vendedor,
    v.valor_total
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
WHERE v.forma_pagamento = 'Pix';


-- ------------------------------------------------------------
-- EXERCÍCIO 09 - Subtotal dos itens
-- ------------------------------------------------------------
SELECT
    iv.id_venda,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario,
    iv.desconto,
    iv.quantidade * iv.valor_unitario AS subtotal_bruto
FROM itens_venda AS iv
INNER JOIN produtos AS p
    ON iv.id_produto = p.id_produto
WHERE iv.quantidade > 2;


-- ------------------------------------------------------------
-- EXERCÍCIO 10 - Total comprado por cliente
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS total_comprado
FROM clientes AS c
INNER JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY total_comprado DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 11 - Desempenho dos vendedores
-- ------------------------------------------------------------
SELECT
    vd.id_vendedor,
    vd.nome_vendedor,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS total_vendido,
    AVG(v.valor_total) AS ticket_medio
FROM vendedores AS vd
INNER JOIN vendas AS v
    ON vd.id_vendedor = v.id_vendedor
GROUP BY vd.id_vendedor, vd.nome_vendedor;


-- ------------------------------------------------------------
-- EXERCÍCIO 12 - Quantidade vendida por produto
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.categoria,
    SUM(iv.quantidade) AS quantidade_total_vendida
FROM produtos AS p
INNER JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto, p.categoria
ORDER BY quantidade_total_vendida DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 13 - Faturamento por categoria
-- ------------------------------------------------------------
SELECT
    p.categoria,
    SUM(iv.quantidade) AS quantidade_total_itens,
    SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)) AS faturamento_liquido
FROM produtos AS p
INNER JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
GROUP BY p.categoria
ORDER BY faturamento_liquido DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 14 - Vendas concluídas em um período
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vd.nome_vendedor,
    v.forma_pagamento,
    v.valor_total
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
WHERE v.status = 'Concluída'
  AND v.data_venda BETWEEN '2026-03-01' AND '2026-06-30'
ORDER BY v.data_venda, v.id_venda;


-- ------------------------------------------------------------
-- EXERCÍCIO 15 - Relatório gerencial
-- ------------------------------------------------------------
SELECT
    vd.nome_vendedor,
    COUNT(DISTINCT v.id_venda) AS quantidade_vendas,
    COUNT(DISTINCT v.id_cliente) AS quantidade_clientes_atendidos,
    SUM(iv.quantidade) AS quantidade_produtos_vendidos,
    SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)) AS faturamento_dos_itens,
    AVG(v.valor_total) AS ticket_medio_das_vendas
FROM vendas AS v
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
INNER JOIN itens_venda AS iv
    ON v.id_venda = iv.id_venda
WHERE v.status = 'Concluída'
GROUP BY vd.id_vendedor, vd.nome_vendedor
ORDER BY faturamento_dos_itens DESC;
