-- ============================================================
-- MISSÕES DA NOITE — TechVendas S/A
-- Cenário: TechVendas S/A
-- Base: exercicios_inner_join_schema.sql
--       + missoes_noite_schema_extra.sql (colunas renda e estoque)
-- Tabelas: clientes, vendedores, produtos, vendas, itens_venda
-- ============================================================


-- ============================================================
-- PARTE 1 — COALESCE
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 01 — Clientes sem compras
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    COALESCE(SUM(v.valor_total), 0) AS valor_total_gasto
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.cidade;


-- ------------------------------------------------------------
-- MISSÃO 02 — Produtos sem vendas
-- ------------------------------------------------------------
SELECT
    p.nome_produto,
    p.preco,
    p.estoque,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_total_vendida
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto, p.preco, p.estoque;


-- ------------------------------------------------------------
-- MISSÃO 03 — Desempenho dos vendedores
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
-- MISSÃO 04 — Classificação de clientes
-- ------------------------------------------------------------
WITH total_por_cliente AS (
    SELECT
        c.id_cliente,
        c.nome_cliente,
        c.cidade,
        COALESCE(SUM(v.valor_total), 0) AS total_gasto
    FROM clientes AS c
    LEFT JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome_cliente, c.cidade
)
SELECT
    nome_cliente,
    cidade,
    total_gasto
FROM total_por_cliente
ORDER BY total_gasto DESC;


-- ============================================================
-- PARTE 2 — BETWEEN e >= / <=
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 05 — Clientes por faixa de renda (com BETWEEN)
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.renda BETWEEN 3000 AND 6000;


-- ------------------------------------------------------------
-- MISSÃO 06 — Mesma faixa, sem BETWEEN (>= e <=)
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.renda >= 3000
  AND c.renda <= 6000;

-- Comparação:
-- Os resultados são IDÊNTICOS. O BETWEEN é apenas uma forma mais
-- legível/compacta de escrever "coluna >= valor_min AND coluna <= valor_max".
-- Internamente, a maioria dos SGBDs (incluindo o MySQL) traduz o
-- BETWEEN exatamente para essa mesma comparação, então não há
-- diferença de resultado nem, normalmente, de desempenho.


-- ------------------------------------------------------------
-- MISSÃO 07 — Período de vendas (1º trimestre de 2025)
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vd.nome_vendedor
FROM vendas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
WHERE v.data_venda BETWEEN '2025-01-01' AND '2025-03-31';


-- ------------------------------------------------------------
-- MISSÃO 08 — Produtos em faixa de preço (sem BETWEEN)
-- ------------------------------------------------------------
SELECT
    p.nome_produto,
    p.preco,
    p.estoque
FROM produtos AS p
WHERE p.preco >= 100
  AND p.preco <= 250;


-- ============================================================
-- PARTE 3 — IN
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 09 — Campanha regional
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.cidade IN ('Curitiba', 'Colombo', 'São José dos Pinhais');


-- ------------------------------------------------------------
-- MISSÃO 10 — Produtos selecionados
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.preco,
    p.estoque
FROM produtos AS p
WHERE p.id_produto IN (1, 3, 5, 7);


-- ------------------------------------------------------------
-- MISSÃO 11 — Vendas de vendedores selecionados
-- ------------------------------------------------------------
SELECT
    vd.nome_vendedor,
    v.id_venda,
    v.data_venda
FROM vendas AS v
INNER JOIN vendedores AS vd
    ON v.id_vendedor = vd.id_vendedor
WHERE vd.id_vendedor IN (1, 3, 5);


-- ============================================================
-- PARTE 4 — LIKE
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 12 — Busca por nomes que começam com "A"
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.nome_cliente LIKE 'A%';


-- ------------------------------------------------------------
-- MISSÃO 13 — Busca por sobrenome "Silva"
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.nome_cliente LIKE '%Silva';


-- ------------------------------------------------------------
-- MISSÃO 14 — Busca por parte do nome ("Eduardo")
-- ------------------------------------------------------------
SELECT
    vd.id_vendedor,
    vd.nome_vendedor
FROM vendedores AS vd
WHERE vd.nome_vendedor LIKE '%Eduardo%';


-- ============================================================
-- PARTE 5 — EXISTS
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 15 — Clientes que já compraram (EXISTS, sem INNER JOIN)
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.cidade
FROM clientes AS c
WHERE EXISTS (
    SELECT 1
    FROM vendas AS v
    WHERE v.id_cliente = c.id_cliente
);


-- ------------------------------------------------------------
-- MISSÃO 16 — Produtos que já foram vendidos
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome_produto,
    p.preco
FROM produtos AS p
WHERE EXISTS (
    SELECT 1
    FROM itens_venda AS iv
    WHERE iv.id_produto = p.id_produto
);


-- ------------------------------------------------------------
-- MISSÃO 17 — Vendedores ativos
-- ------------------------------------------------------------
SELECT
    vd.id_vendedor,
    vd.nome_vendedor
FROM vendedores AS vd
WHERE EXISTS (
    SELECT 1
    FROM vendas AS v
    WHERE v.id_vendedor = vd.id_vendedor
);


-- ------------------------------------------------------------
-- MISSÃO 18 — Clientes que NÃO compraram
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM vendas AS v
    WHERE v.id_cliente = c.id_cliente
);


-- ============================================================
-- PARTE 6 — Combinando os conceitos
-- ============================================================

-- ------------------------------------------------------------
-- MISSÃO 19 — Clientes de alto potencial (BETWEEN + IN + EXISTS)
-- ------------------------------------------------------------
SELECT
    c.nome_cliente,
    c.cidade,
    c.renda
FROM clientes AS c
WHERE c.renda BETWEEN 5000 AND 8000
  AND c.cidade IN ('Curitiba', 'Colombo', 'São José dos Pinhais')
  AND EXISTS (
        SELECT 1
        FROM vendas AS v
        WHERE v.id_cliente = c.id_cliente
  );


-- ------------------------------------------------------------
-- MISSÃO 20 — Produtos estratégicos (BETWEEN + EXISTS)
-- ------------------------------------------------------------
SELECT
    p.nome_produto,
    p.preco,
    p.estoque
FROM produtos AS p
WHERE p.preco BETWEEN 100 AND 300
  AND p.estoque > 20
  AND EXISTS (
        SELECT 1
        FROM itens_venda AS iv
        WHERE iv.id_produto = p.id_produto
  );
