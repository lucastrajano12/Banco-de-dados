create database prova_1
use prova_1

select * from garantia_safra;

WITH
 
-- Exerc 1.1 
base_2020 AS (
    SELECT *
    FROM garantia_safra
    WHERE ano_referencia >= 2020
),
 
-- Exerc 1.2 
valor_qtd_uf_ano AS (
    SELECT
        sigla_uf,
        ano_referencia,
        COALESCE(SUM(valor_parcela), 0) AS valor_total,
        COUNT(*)                       AS qtd_parcelas
    FROM base_2020
    GROUP BY sigla_uf, ano_referencia
),
 
-- Exerc 1.3
beneficiarios_municipios_uf_ano AS (
    SELECT
        sigla_uf,
        ano_referencia,
        COUNT(DISTINCT nis_favorecido) AS beneficiarios_unicos,
        COUNT(DISTINCT id_municipio)   AS municipios_atendidos
    FROM base_2020
    GROUP BY sigla_uf, ano_referencia
),
 
-- Exerc 1.4 
estatisticas_uf_ano AS (
    SELECT
        sigla_uf,
        ano_referencia,
        COALESCE(AVG(valor_parcela), 0) AS ticket_medio,
        COALESCE(MAX(valor_parcela), 0) AS maior_valor
    FROM base_2020
    GROUP BY sigla_uf, ano_referencia
),
 
-- Exerc 1.5 
faixas_uf_ano AS (
    SELECT
        sigla_uf,
        ano_referencia,
        SUM(CASE WHEN valor_parcela >= 800 THEN 1 ELSE 0 END)                          AS qtd_alta,
        SUM(CASE WHEN valor_parcela >= 500 AND valor_parcela < 800 THEN 1 ELSE 0 END)  AS qtd_media,
        SUM(CASE WHEN valor_parcela < 500 THEN 1 ELSE 0 END)                           AS qtd_baixa
    FROM base_2020
    GROUP BY sigla_uf, ano_referencia
)
 
-- Exerc 1.6 Relatório Final Da Parte 1
SELECT
    v.sigla_uf,
    v.ano_referencia                                   AS ano,
    v.valor_total,
    v.qtd_parcelas,
    bm.beneficiarios_unicos,
    bm.municipios_atendidos,
    ROUND(e.ticket_medio, 2)                           AS ticket_medio,
    e.maior_valor,
    f.qtd_alta,
    f.qtd_media,
    f.qtd_baixa,
    CASE
        WHEN e.ticket_medio >= 800 THEN 'TICKET_ALTO'
        WHEN e.ticket_medio >= 500 THEN 'TICKET_MEDIO'
        ELSE 'TICKET_BAIXO'
    END AS classificacao_ticket
FROM valor_qtd_uf_ano v
JOIN beneficiarios_municipios_uf_ano bm
    ON v.sigla_uf = bm.sigla_uf AND v.ano_referencia = bm.ano_referencia
JOIN estatisticas_uf_ano e
    ON v.sigla_uf = e.sigla_uf AND v.ano_referencia = e.ano_referencia
JOIN faixas_uf_ano f
    ON v.sigla_uf = f.sigla_uf AND v.ano_referencia = f.ano_referencia
ORDER BY v.ano_referencia, v.valor_total DESC;
 
