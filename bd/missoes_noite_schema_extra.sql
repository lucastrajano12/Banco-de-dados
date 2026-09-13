-- ============================================================
-- SCHEMA DE APOIO: MISSÕES DA NOITE
-- Extensão do schema já usado (exercicios_inner_join_schema.sql)
--
-- O enunciado das Missões da Noite pede colunas que não existem
-- nas tabelas originais (clientes.renda e produtos.estoque), além
-- de um vendedor com "Eduardo" no nome para a Missão 14. Este
-- script adiciona essas colunas e preenche com valores sintéticos
-- (gerados a partir do próprio ID) só para fins didáticos, e
-- cadastra o vendedor extra.
--
-- Execute este script DEPOIS de exercicios_inner_join_schema.sql.
-- ============================================================

USE db_2_bim;  -- ajuste o nome do banco se necessário

-- ------------------------------------------------------------
-- Coluna "renda" em clientes
-- ------------------------------------------------------------
ALTER TABLE clientes
    ADD COLUMN renda DECIMAL(10,2) NOT NULL DEFAULT 0;

-- Valores sintéticos entre aproximadamente R$ 2.000 e R$ 11.000,
-- variando de acordo com o id_cliente para gerar uma distribuição
-- realista o suficiente para os exercícios de faixa (BETWEEN).
UPDATE clientes
SET renda = 2000 + MOD(id_cliente * 733, 9001);


-- ------------------------------------------------------------
-- Coluna "estoque" em produtos
-- ------------------------------------------------------------
ALTER TABLE produtos
    ADD COLUMN estoque INT NOT NULL DEFAULT 0;

-- Valores sintéticos entre 5 e 100 unidades.
UPDATE produtos
SET estoque = 5 + MOD(id_produto * 37, 96);


-- ------------------------------------------------------------
-- Vendedor extra com "Eduardo" no nome (necessário para a
-- Missão 14 — Busca por parte do nome).
-- ------------------------------------------------------------
INSERT INTO vendedores (id_vendedor, nome_vendedor, setor) VALUES
    (51, 'Carlos Eduardo Ramos', 'Corporativo');
