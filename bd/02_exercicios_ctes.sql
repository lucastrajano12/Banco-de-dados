-- ============================================================
-- EXERCÍCIO: Exercícios CTEs
-- Tema: WITH (Common Table Expressions), agregações e ranking
-- Base: db_2_bim / tabela vendas (ver warming_up_schema.sql)
-- ============================================================

USE db_2_bim;

-- ------------------------------------------------------------
-- Questão 1 — Vendas concluídas
-- ------------------------------------------------------------
WITH vendas_concluidas AS (
    SELECT
        id_venda,
        data_venda,
        nome_cliente,
        nome_produto,
        valor_total,
        vendedor
    FROM vendas
    WHERE status_venda = 'Concluída'
)
SELECT
    id_venda,
    data_venda,
    nome_cliente,
    nome_produto,
    valor_total,
    vendedor
FROM vendas_concluidas
ORDER BY valor_total DESC;


-- ------------------------------------------------------------
-- Questão 2 — Faturamento por categoria
-- ------------------------------------------------------------
WITH resumo_categorias AS (
    SELECT
        categoria,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
)
SELECT
    categoria,
    quantidade_vendas,
    total_produtos_vendidos,
    faturamento_total,
    valor_medio_vendas
FROM resumo_categorias
WHERE faturamento_total > 10000.00
ORDER BY faturamento_total DESC;


-- ------------------------------------------------------------
-- Questão 3 — Desempenho dos vendedores
-- ------------------------------------------------------------
WITH desempenho_vendedores AS (
    SELECT
        vendedor,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS valor_total_vendido,
        AVG(valor_total) AS ticket_medio
    FROM vendas
    GROUP BY vendedor
)
SELECT
    vendedor,
    quantidade_vendas,
    total_produtos_vendidos,
    valor_total_vendido,
    ticket_medio
FROM desempenho_vendedores
ORDER BY valor_total_vendido DESC
LIMIT 3;


-- ------------------------------------------------------------
-- Questão 4 — Estados com faturamento acima da média
-- (três CTEs encadeadas)
-- ------------------------------------------------------------
WITH vendas_validas AS (
    SELECT *
    FROM vendas
    WHERE quantidade > 0
      AND status_venda <> 'Cancelada'
),
faturamento_estados AS (
    SELECT
        estado_cliente,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total
    FROM vendas_validas
    GROUP BY estado_cliente
),
media_faturamento AS (
    SELECT AVG(faturamento_total) AS media_geral
    FROM faturamento_estados
)
SELECT
    fe.estado_cliente,
    fe.quantidade_vendas,
    fe.total_produtos_vendidos,
    fe.faturamento_total,
    mf.media_geral,
    fe.faturamento_total - mf.media_geral AS diferenca_para_media
FROM faturamento_estados fe
CROSS JOIN media_faturamento mf
WHERE fe.faturamento_total > mf.media_geral
ORDER BY fe.faturamento_total DESC;


-- ------------------------------------------------------------
-- Desafio adicional — Questão 2 reescrita com subquery
-- ------------------------------------------------------------
SELECT
    categoria,
    quantidade_vendas,
    total_produtos_vendidos,
    faturamento_total,
    valor_medio_vendas
FROM (
    SELECT
        categoria,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
) AS resumo_categorias
WHERE faturamento_total > 10000.00
ORDER BY faturamento_total DESC;

-- Comparação CTE x Subquery:
--
-- Legibilidade: a CTE é mais legível porque nomeia o passo intermediário
-- (resumo_categorias) antes da consulta principal, deixando claro o que
-- cada bloco representa. Na subquery, é preciso "ler de dentro para fora"
-- para entender a lógica.
--
-- Organização: a CTE separa visualmente a etapa de agregação da etapa de
-- filtro/ordenação final, enquanto na subquery tudo fica aninhado dentro
-- do FROM, misturando os níveis de consulta.
--
-- Níveis de aninhamento: a subquery adiciona um nível de aninhamento
-- (subconsulta dentro do FROM), enquanto a CTE mantém a consulta principal
-- "no nível zero", tornando o SQL mais plano e fácil de acompanhar.
--
-- Facilidade de manutenção: a CTE é mais fácil de manter e reaproveitar,
-- pois poderia ser referenciada mais de uma vez na mesma consulta (ex.:
-- em um JOIN) sem repetir a lógica de agregação. A subquery, se precisar
-- ser reutilizada, teria que ser copiada novamente em outro trecho da
-- consulta, aumentando o risco de erro e duplicação de código.
