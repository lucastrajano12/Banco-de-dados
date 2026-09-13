-- ============================================================
-- CHALLENGE NIGHT II — JOINs AVANÇADOS
-- Cenário: TechVendas S/A
-- Base: exercicios_inner_join_schema.sql (clientes, vendedores,
--       produtos, vendas, itens_venda)
-- Exercícios 12 e 13 usam também: clientes_integracao_schema.sql
--
-- Regras seguidas:
-- 1. JOIN mais adequado para cada caso (INNER, LEFT, RIGHT, FULL OUTER).
-- 2. CTE sempre que facilita a leitura/organização da solução.
-- 3. Aliases em todas as tabelas.
-- 4. Sem SELECT *.
-- 5. Código comentado e indentado.
--
-- Observação de compatibilidade: MySQL não possui FULL OUTER JOIN
-- nativo. Nos exercícios 12 e 15, ele é simulado com
-- LEFT JOIN + RIGHT JOIN + UNION.
-- ============================================================


-- ------------------------------------------------------------
-- EXERCÍCIO 01 — Clientes e Compras
-- ------------------------------------------------------------
-- LEFT JOIN: precisamos manter TODOS os clientes, mesmo os que
-- nunca compraram (por isso vendas fica do lado "opcional").
SELECT
    c.nome_cliente,
    c.cidade,
    COUNT(v.id_venda) AS quantidade_compras,
    COALESCE(SUM(v.valor_total), 0) AS valor_total_comprado
FROM clientes AS c
LEFT JOIN vendas AS v
    ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.cidade
ORDER BY valor_total_comprado DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 02 — Produtos Comercializados
-- ------------------------------------------------------------
-- LEFT JOIN: todo produto cadastrado deve aparecer, mesmo os
-- que nunca tiveram um item de venda associado.
SELECT
    p.nome_produto,
    p.categoria,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida,
    COALESCE(SUM(iv.quantidade * iv.valor_unitario), 0) AS faturamento
FROM produtos AS p
LEFT JOIN itens_venda AS iv
    ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto, p.categoria
ORDER BY faturamento DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 03 — Desempenho dos Vendedores
-- ------------------------------------------------------------
-- LEFT JOIN: todo vendedor cadastrado deve aparecer, mesmo os
-- que ainda não realizaram nenhuma venda.
SELECT
    vd.nome_vendedor,
    vd.setor,
    COUNT(v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(v.valor_total), 0) AS faturamento
FROM vendedores AS vd
LEFT JOIN vendas AS v
    ON vd.id_vendedor = v.id_vendedor
GROUP BY vd.id_vendedor, vd.nome_vendedor, vd.setor
ORDER BY faturamento DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 04 — Auditoria de Clientes
-- ------------------------------------------------------------
-- CTE com quem já comprou (INNER JOIN) + LEFT JOIN para achar,
-- por diferença, quem nunca apareceu nessa lista (anti-join).
WITH clientes_compradores AS (
    SELECT DISTINCT c.id_cliente
    FROM clientes AS c
    INNER JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
)
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.cidade
FROM clientes AS c
LEFT JOIN clientes_compradores AS cc
    ON c.id_cliente = cc.id_cliente
WHERE cc.id_cliente IS NULL;


-- ------------------------------------------------------------
-- EXERCÍCIO 05 — Auditoria de Produtos
-- ------------------------------------------------------------
WITH produtos_vendidos AS (
    SELECT DISTINCT p.id_produto
    FROM produtos AS p
    INNER JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
)
SELECT
    p.id_produto,
    p.nome_produto,
    p.categoria
FROM produtos AS p
LEFT JOIN produtos_vendidos AS pv
    ON p.id_produto = pv.id_produto
WHERE pv.id_produto IS NULL;


-- ------------------------------------------------------------
-- EXERCÍCIO 06 — Ranking Comercial
-- ------------------------------------------------------------
-- Faixas de classificação ilustrativas: podem ser ajustadas
-- conforme a meta comercial real da empresa.
WITH faturamento_vendedores AS (
    SELECT
        vd.id_vendedor,
        vd.nome_vendedor,
        COALESCE(SUM(v.valor_total), 0) AS faturamento_total
    FROM vendedores AS vd
    LEFT JOIN vendas AS v
        ON vd.id_vendedor = v.id_vendedor
    GROUP BY vd.id_vendedor, vd.nome_vendedor
)
SELECT
    nome_vendedor,
    faturamento_total,
    CASE
        WHEN faturamento_total = 0 THEN 'Sem vendas'
        WHEN faturamento_total >= 20000 THEN 'Excelente'
        WHEN faturamento_total >= 10000 THEN 'Bom'
        ELSE 'Regular'
    END AS classificacao
FROM faturamento_vendedores
ORDER BY faturamento_total DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 07 — Produtos acima da Média
-- ------------------------------------------------------------
WITH faturamento_produtos AS (
    SELECT
        p.id_produto,
        p.nome_produto,
        COALESCE(SUM(iv.quantidade * iv.valor_unitario), 0) AS faturamento_produto
    FROM produtos AS p
    LEFT JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
    GROUP BY p.id_produto, p.nome_produto
),
media_geral AS (
    SELECT AVG(faturamento_produto) AS media_faturamento
    FROM faturamento_produtos
)
SELECT
    fp.nome_produto,
    fp.faturamento_produto,
    mg.media_faturamento
FROM faturamento_produtos AS fp
CROSS JOIN media_geral AS mg
WHERE fp.faturamento_produto > mg.media_faturamento
ORDER BY fp.faturamento_produto DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 08 — Categorias Estratégicas
-- ------------------------------------------------------------
WITH produtos_status AS (
    SELECT
        p.id_produto,
        p.categoria,
        COALESCE(SUM(iv.quantidade * iv.valor_unitario), 0) AS faturamento_produto,
        CASE WHEN COUNT(iv.id_item) > 0 THEN 1 ELSE 0 END AS foi_vendido
    FROM produtos AS p
    LEFT JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
    GROUP BY p.id_produto, p.categoria
)
SELECT
    categoria,
    COUNT(*) AS quantidade_produtos,
    SUM(foi_vendido) AS produtos_vendidos,
    SUM(1 - foi_vendido) AS produtos_nunca_vendidos,
    SUM(faturamento_produto) AS faturamento
FROM produtos_status
GROUP BY categoria
ORDER BY faturamento DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 09 — Dashboard de Clientes
-- ------------------------------------------------------------
-- Faixas de classificação ilustrativas.
WITH compras_cliente AS (
    SELECT
        c.id_cliente,
        c.nome_cliente,
        COUNT(v.id_venda) AS quantidade_compras,
        COALESCE(SUM(v.valor_total), 0) AS valor_total,
        COALESCE(AVG(v.valor_total), 0) AS ticket_medio
    FROM clientes AS c
    LEFT JOIN vendas AS v
        ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome_cliente
)
SELECT
    nome_cliente,
    quantidade_compras,
    valor_total,
    ticket_medio,
    CASE
        WHEN quantidade_compras = 0 THEN 'Sem compras'
        WHEN valor_total >= 5000 THEN 'Cliente VIP'
        WHEN valor_total >= 1000 THEN 'Cliente Regular'
        ELSE 'Cliente Ocasional'
    END AS classificacao
FROM compras_cliente
ORDER BY valor_total DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 10 — Dashboard de Produtos
-- ------------------------------------------------------------
WITH vendas_produto AS (
    SELECT
        p.id_produto,
        p.nome_produto,
        COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida,
        COALESCE(SUM(iv.quantidade * iv.valor_unitario), 0) AS valor_vendido
    FROM produtos AS p
    LEFT JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
    GROUP BY p.id_produto, p.nome_produto
),
total_vendas AS (
    SELECT SUM(valor_vendido) AS faturamento_total
    FROM vendas_produto
)
SELECT
    vp.nome_produto,
    vp.quantidade_vendida,
    vp.valor_vendido,
    ROUND(vp.valor_vendido / NULLIF(tv.faturamento_total, 0) * 100, 2) AS percentual_participacao
FROM vendas_produto AS vp
CROSS JOIN total_vendas AS tv
ORDER BY vp.valor_vendido DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 11 — Auditoria Completa
-- ------------------------------------------------------------
-- JOIN escolhido: LEFT JOIN de produtos com a CTE de produtos
-- vendidos. Isso é necessário porque queremos TODOS os produtos
-- cadastrados no relatório final, inclusive os que nunca tiveram
-- correspondência em itens_venda. Um INNER JOIN aqui excluiria
-- justamente os produtos "nunca vendidos", que é a informação
-- que o exercício pede para identificar. Dentro da CTE, o
-- INNER JOIN é apropriado, pois ali o objetivo é apenas obter a
-- lista de produtos que efetivamente têm correspondência em vendas.
WITH produtos_vendidos AS (
    SELECT DISTINCT p.id_produto
    FROM produtos AS p
    INNER JOIN itens_venda AS iv
        ON p.id_produto = iv.id_produto
)
SELECT
    p.id_produto,
    p.nome_produto,
    CASE
        WHEN pv.id_produto IS NOT NULL THEN 'Vendido'
        ELSE 'Nunca vendido'
    END AS situacao
FROM produtos AS p
LEFT JOIN produtos_vendidos AS pv
    ON p.id_produto = pv.id_produto
ORDER BY situacao, p.nome_produto;


-- ------------------------------------------------------------
-- EXERCÍCIO 12 — Integração de Sistemas
-- ------------------------------------------------------------
-- Usa clientes_integracao_schema.sql (clientes_techvendas e
-- clientes_empresa_adquirida). Comparação feita pelo e-mail,
-- já que os IDs são diferentes entre os dois sistemas.
--
-- MySQL não tem FULL OUTER JOIN nativo, então ele é simulado
-- com LEFT JOIN + RIGHT JOIN + UNION (UNION já remove duplicatas).
SELECT
    COALESCE(t.nome_cliente, a.nome_cliente) AS nome_cliente,
    COALESCE(t.email, a.email) AS email,
    CASE
        WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente em ambas as bases'
        WHEN t.email IS NOT NULL AND a.email IS NULL THEN 'Somente TechVendas'
        WHEN t.email IS NULL AND a.email IS NOT NULL THEN 'Somente empresa adquirida'
    END AS situacao
FROM clientes_techvendas AS t
LEFT JOIN clientes_empresa_adquirida AS a
    ON t.email = a.email

UNION

SELECT
    COALESCE(t.nome_cliente, a.nome_cliente) AS nome_cliente,
    COALESCE(t.email, a.email) AS email,
    CASE
        WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente em ambas as bases'
        WHEN t.email IS NOT NULL AND a.email IS NULL THEN 'Somente TechVendas'
        WHEN t.email IS NULL AND a.email IS NOT NULL THEN 'Somente empresa adquirida'
    END AS situacao
FROM clientes_techvendas AS t
RIGHT JOIN clientes_empresa_adquirida AS a
    ON t.email = a.email

ORDER BY situacao, nome_cliente;

-- Caso o SGBD suporte FULL OUTER JOIN nativamente (ex.: PostgreSQL),
-- a mesma consulta pode ser escrita de forma mais direta:
--
-- SELECT
--     COALESCE(t.nome_cliente, a.nome_cliente) AS nome_cliente,
--     COALESCE(t.email, a.email) AS email,
--     CASE
--         WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente em ambas as bases'
--         WHEN t.email IS NOT NULL AND a.email IS NULL THEN 'Somente TechVendas'
--         WHEN t.email IS NULL AND a.email IS NOT NULL THEN 'Somente empresa adquirida'
--     END AS situacao
-- FROM clientes_techvendas AS t
-- FULL OUTER JOIN clientes_empresa_adquirida AS a
--     ON t.email = a.email
-- ORDER BY situacao, nome_cliente;


-- ------------------------------------------------------------
-- EXERCÍCIO 13 — Auditoria de Cadastros
-- ------------------------------------------------------------
-- "Base antiga" = clientes_techvendas (já existia antes da compra).
-- "Base nova" = clientes_empresa_adquirida (veio com a aquisição).
WITH comparativo AS (
    SELECT
        COALESCE(t.email, a.email) AS email,
        CASE
            WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente nas duas bases'
            WHEN t.email IS NOT NULL AND a.email IS NULL THEN 'Somente na base antiga'
            WHEN t.email IS NULL AND a.email IS NOT NULL THEN 'Somente na base nova'
        END AS situacao
    FROM clientes_techvendas AS t
    LEFT JOIN clientes_empresa_adquirida AS a
        ON t.email = a.email

    UNION

    SELECT
        COALESCE(t.email, a.email) AS email,
        CASE
            WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente nas duas bases'
            WHEN t.email IS NOT NULL AND a.email IS NULL THEN 'Somente na base antiga'
            WHEN t.email IS NULL AND a.email IS NOT NULL THEN 'Somente na base nova'
        END AS situacao
    FROM clientes_techvendas AS t
    RIGHT JOIN clientes_empresa_adquirida AS a
        ON t.email = a.email
)
SELECT
    situacao,
    COUNT(*) AS quantidade_clientes
FROM comparativo
GROUP BY situacao
ORDER BY situacao;


-- ------------------------------------------------------------
-- EXERCÍCIO 14 — Dashboard Executivo
-- ------------------------------------------------------------
WITH resumo_vendedor AS (
    SELECT
        vd.id_vendedor,
        vd.nome_vendedor,
        COUNT(DISTINCT v.id_cliente) AS quantidade_clientes,
        COUNT(v.id_venda) AS quantidade_vendas,
        COALESCE(AVG(v.valor_total), 0) AS ticket_medio
    FROM vendedores AS vd
    LEFT JOIN vendas AS v
        ON vd.id_vendedor = v.id_vendedor
    GROUP BY vd.id_vendedor, vd.nome_vendedor
),
faturamento_cliente_vendedor AS (
    SELECT
        v.id_vendedor,
        c.nome_cliente,
        SUM(v.valor_total) AS faturamento_cliente,
        ROW_NUMBER() OVER (
            PARTITION BY v.id_vendedor
            ORDER BY SUM(v.valor_total) DESC
        ) AS ranking
    FROM vendas AS v
    INNER JOIN clientes AS c
        ON v.id_cliente = c.id_cliente
    GROUP BY v.id_vendedor, c.nome_cliente
),
melhor_cliente AS (
    SELECT id_vendedor, nome_cliente AS melhor_cliente
    FROM faturamento_cliente_vendedor
    WHERE ranking = 1
),
faturamento_categoria_vendedor AS (
    SELECT
        v.id_vendedor,
        p.categoria,
        SUM(iv.quantidade * iv.valor_unitario) AS faturamento_categoria,
        ROW_NUMBER() OVER (
            PARTITION BY v.id_vendedor
            ORDER BY SUM(iv.quantidade * iv.valor_unitario) DESC
        ) AS ranking
    FROM vendas AS v
    INNER JOIN itens_venda AS iv
        ON v.id_venda = iv.id_venda
    INNER JOIN produtos AS p
        ON iv.id_produto = p.id_produto
    GROUP BY v.id_vendedor, p.categoria
),
melhor_categoria AS (
    SELECT id_vendedor, categoria AS melhor_categoria
    FROM faturamento_categoria_vendedor
    WHERE ranking = 1
),
faturamento_produto_vendedor AS (
    SELECT
        v.id_vendedor,
        p.nome_produto,
        SUM(iv.quantidade * iv.valor_unitario) AS faturamento_produto,
        ROW_NUMBER() OVER (
            PARTITION BY v.id_vendedor
            ORDER BY SUM(iv.quantidade * iv.valor_unitario) DESC
        ) AS ranking
    FROM vendas AS v
    INNER JOIN itens_venda AS iv
        ON v.id_venda = iv.id_venda
    INNER JOIN produtos AS p
        ON iv.id_produto = p.id_produto
    GROUP BY v.id_vendedor, p.nome_produto
),
melhor_produto AS (
    SELECT id_vendedor, nome_produto AS melhor_produto
    FROM faturamento_produto_vendedor
    WHERE ranking = 1
)
SELECT
    rv.nome_vendedor,
    rv.quantidade_clientes,
    rv.quantidade_vendas,
    rv.ticket_medio,
    mc.melhor_cliente,
    mcat.melhor_categoria,
    mp.melhor_produto
FROM resumo_vendedor AS rv
LEFT JOIN melhor_cliente AS mc
    ON rv.id_vendedor = mc.id_vendedor
LEFT JOIN melhor_categoria AS mcat
    ON rv.id_vendedor = mcat.id_vendedor
LEFT JOIN melhor_produto AS mp
    ON rv.id_vendedor = mp.id_vendedor
ORDER BY rv.quantidade_vendas DESC;


-- ------------------------------------------------------------
-- EXERCÍCIO 15 — Painel de Auditoria Geral
-- ------------------------------------------------------------
WITH clientes_compradores AS (
    SELECT DISTINCT v.id_cliente
    FROM vendas AS v
),
-- FULL OUTER JOIN simulado (LEFT + RIGHT + UNION), já que o MySQL
-- não possui suporte nativo. Como existe uma FK entre
-- vendas.id_cliente e clientes.id_cliente, todo comprador já é
-- necessariamente um cliente cadastrado — mas a estrutura abaixo
-- continuaria funcionando normalmente mesmo se essa garantia
-- não existisse (ex.: dados vindos de sistemas diferentes).
auditoria_clientes AS (
    SELECT
        c.id_cliente,
        CASE WHEN cc.id_cliente IS NOT NULL THEN 1 ELSE 0 END AS esta_ativo
    FROM clientes AS c
    LEFT JOIN clientes_compradores AS cc
        ON c.id_cliente = cc.id_cliente

    UNION

    SELECT
        c.id_cliente,
        CASE WHEN cc.id_cliente IS NOT NULL THEN 1 ELSE 0 END AS esta_ativo
    FROM clientes AS c
    RIGHT JOIN clientes_compradores AS cc
        ON c.id_cliente = cc.id_cliente
),
resumo_clientes AS (
    SELECT
        COUNT(*) AS clientes_cadastrados,
        SUM(esta_ativo) AS clientes_ativos,
        SUM(1 - esta_ativo) AS clientes_sem_compras
    FROM auditoria_clientes
),
produtos_vendidos AS (
    SELECT DISTINCT iv.id_produto
    FROM itens_venda AS iv
),
-- RIGHT JOIN: produtos é a tabela "âncora" (lado direito), o que
-- garante que todo produto cadastrado apareça no resultado, mesmo
-- os que nunca tiveram um item de venda associado.
auditoria_produtos AS (
    SELECT
        p.id_produto,
        CASE WHEN pv.id_produto IS NOT NULL THEN 1 ELSE 0 END AS foi_vendido
    FROM produtos_vendidos AS pv
    RIGHT JOIN produtos AS p
        ON pv.id_produto = p.id_produto
),
resumo_produtos AS (
    SELECT
        COUNT(*) AS produtos_cadastrados,
        SUM(foi_vendido) AS produtos_vendidos,
        SUM(1 - foi_vendido) AS produtos_sem_vendas
    FROM auditoria_produtos
),
-- LEFT JOIN + HAVING: mantém todos os vendedores no agrupamento e
-- usa HAVING para filtrar apenas os grupos com pelo menos 1 venda.
vendedores_com_vendas AS (
    SELECT vd.id_vendedor
    FROM vendedores AS vd
    LEFT JOIN vendas AS v
        ON vd.id_vendedor = v.id_vendedor
    GROUP BY vd.id_vendedor
    HAVING COUNT(v.id_venda) > 0
),
resumo_vendedores AS (
    SELECT
        COUNT(*) AS vendedores_cadastrados,
        (SELECT COUNT(*) FROM vendedores_com_vendas) AS vendedores_ativos,
        COUNT(*) - (SELECT COUNT(*) FROM vendedores_com_vendas) AS vendedores_sem_vendas
    FROM vendedores
)
SELECT
    rc.clientes_cadastrados,
    COALESCE(rc.clientes_ativos, 0) AS clientes_ativos,
    COALESCE(rc.clientes_sem_compras, 0) AS clientes_sem_compras,
    rp.produtos_cadastrados,
    COALESCE(rp.produtos_vendidos, 0) AS produtos_vendidos,
    COALESCE(rp.produtos_sem_vendas, 0) AS produtos_sem_vendas,
    rv.vendedores_cadastrados,
    COALESCE(rv.vendedores_ativos, 0) AS vendedores_ativos,
    COALESCE(rv.vendedores_sem_vendas, 0) AS vendedores_sem_vendas
FROM resumo_clientes AS rc
CROSS JOIN resumo_produtos AS rp
CROSS JOIN resumo_vendedores AS rv;
