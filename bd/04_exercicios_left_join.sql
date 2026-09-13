-- ============================================================
-- EXERCÍCIOS DE FIXAÇÃO - LEFT JOIN (Aula 03)
-- Cenário: TechVendas S/A
-- Base: mesmas tabelas da aula 02 (exercicios_inner_join_schema.sql)
-- Tabelas: clientes, vendedores, produtos, vendas, itens_venda
--
-- Regras seguidas:
-- 1. LEFT JOIN explícito em todas as questões.
-- 2. Aliases para as tabelas.
-- 3. Sem SELECT *.
-- 4. Código indentado e organizado.
-- ============================================================


-- ------------------------------------------------------------
-- EXERCÍCIO 01 - Todos os clientes
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.cidade,
    v.id_venda,
    v.data_venda
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 02 - Clientes sem compras
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
-- EXERCÍCIO 03 - Todos os vendedores
-- ------------------------------------------------------------
SELECT
    vd.id_vendedor,
    vd.nome_vendedor,
    vd.setor,
    v.id_venda
FROM vendedores AS vd
LEFT JOIN vendas AS v
    ON vd.id_vendedor = v.id_vendedor;


-- ------------------------------------------------------------
-- EXERCÍCIO 04 - Vendedores sem vendas
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
-- EXERCÍCIO 05 - Todos os produtos
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.categoria,
    iv.quantidade
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 06 - Produtos nunca vendidos
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
-- EXERCÍCIO 07 - Quantidade de vendas por cliente
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    COUNT(v.id_venda) AS quantidade_vendas
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 08 - Valor total comprado por cliente
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    COALESCE(SUM(v.valor_total), 0) AS total_comprado
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 09 - Quantidade vendida por produto
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_total_vendida
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 10 - Produtos sem movimentação
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.categoria,
    p.preco
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
WHERE iv.id_item IS NULL;


-- ------------------------------------------------------------
-- EXERCÍCIO 11 - Relatório completo de clientes
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    COUNT(v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(v.valor_total), 0) AS total_comprado
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.cidade
ORDER BY total_comprado DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 12 - Relatório de vendedores
-- ------------------------------------------------------------
SELECT
    vd.nome_vendedor,
    COUNT(v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(v.valor_total), 0) AS faturamento_total
FROM vendedores AS vd
LEFT JOIN vendas AS v
    ON vd.id_vendedor = v.id_vendedor
GROUP BY vd.id_vendedor, vd.nome_vendedor;


-- ------------------------------------------------------------
-- EXERCÍCIO 13 - Produtos e categorias
-- ------------------------------------------------------------
SELECT
    p.categoria,
    p.nome_produto,
    iv.quantidade AS quantidade_vendida
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
ORDER BY p.categoria, p.nome_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 14 - Clientes e última venda
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    MAX(v.data_venda) AS data_da_ultima_venda
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 15 - Dashboard Gerencial
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.cidade,
    COUNT(v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(v.valor_total), 0) AS valor_total_comprado,
    MIN(v.data_venda) AS data_primeira_compra,
    MAX(v.data_venda) AS data_ultima_compra
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.cidade
ORDER BY valor_total_comprado DESC;
