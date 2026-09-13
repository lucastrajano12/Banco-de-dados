-- ============================================================
-- EXERCÍCIO: Warming Up
-- Tema: UPDATE, DELETE, GROUP BY e Funções de Agregação
-- Base: db_2_bim / tabela vendas (ver warming_up.sql)
-- ============================================================

USE db_2_bim;

-- ------------------------------------------------------------
-- Questão 1 — Atualização da forma de pagamento
-- Vendas com forma de pagamento "Cartao" -> "Cartão de Crédito"
-- ------------------------------------------------------------
UPDATE vendas
SET forma_pagamento = 'Cartão de Crédito'
WHERE forma_pagamento = 'Cartao';


-- ------------------------------------------------------------
-- Questão 2 — Atualização do status da venda
-- Vendas "Pendente" realizadas antes de 2025-01-01 -> "Cancelada"
-- ------------------------------------------------------------
UPDATE vendas
SET status_venda = 'Cancelada'
WHERE status_venda = 'Pendente'
  AND data_venda < '2025-01-01';


-- ------------------------------------------------------------
-- Questão 3 — Reajuste do valor unitário
-- Produtos da categoria "Informática" -> +10% no valor_unitario
-- ------------------------------------------------------------
UPDATE vendas
SET valor_unitario = valor_unitario * 1.10
WHERE categoria = 'Informática';


-- ------------------------------------------------------------
-- Questão 4 — Correção do valor total
-- Venda de código 10: recalcular valor_total = quantidade * valor_unitario
-- ------------------------------------------------------------
UPDATE vendas
SET valor_total = quantidade * valor_unitario
WHERE id_venda = 10;


-- ------------------------------------------------------------
-- Questão 5 — Exclusão de vendas canceladas
-- Vendas "Cancelada" realizadas antes de 2024-01-01
-- ------------------------------------------------------------
DELETE FROM vendas
WHERE status_venda = 'Cancelada'
  AND data_venda < '2024-01-01';


-- ------------------------------------------------------------
-- Questão 6 — Exclusão de registros inválidos
-- Vendas com quantidade <= 0
-- ------------------------------------------------------------
DELETE FROM vendas
WHERE quantidade <= 0;


-- ------------------------------------------------------------
-- Questão 7 — Quantidade de vendas por categoria
-- ------------------------------------------------------------
SELECT
    categoria,
    COUNT(*) AS quantidade_vendas
FROM vendas
GROUP BY categoria
ORDER BY quantidade_vendas DESC;


-- ------------------------------------------------------------
-- Questão 8 — Resumo financeiro por categoria
-- ------------------------------------------------------------
SELECT
    categoria,
    SUM(valor_total) AS valor_total_vendido,
    AVG(valor_total) AS valor_medio_venda,
    MIN(valor_total) AS menor_valor_venda,
    MAX(valor_total) AS maior_valor_venda
FROM vendas
GROUP BY categoria
ORDER BY valor_total_vendido DESC;


-- ------------------------------------------------------------
-- Questão 9 — Total vendido por vendedor
-- ------------------------------------------------------------
SELECT
    vendedor,
    COUNT(*) AS quantidade_vendas,
    SUM(quantidade) AS total_produtos_vendidos,
    SUM(valor_total) AS valor_total_vendido
FROM vendas
GROUP BY vendedor
ORDER BY valor_total_vendido DESC;


-- ------------------------------------------------------------
-- Questão 10 — Relatório de vendas por estado
-- Somente estados com faturamento total > R$ 5.000,00
-- ------------------------------------------------------------
SELECT
    estado_cliente,
    COUNT(*) AS quantidade_vendas,
    SUM(quantidade) AS total_produtos_vendidos,
    SUM(valor_total) AS faturamento_total,
    AVG(valor_total) AS ticket_medio
FROM vendas
GROUP BY estado_cliente
HAVING SUM(valor_total) > 5000.00
ORDER BY faturamento_total DESC;
