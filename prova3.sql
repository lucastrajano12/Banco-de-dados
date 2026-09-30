
use prova_1

select * from garantia_safra;

 WITH
 
-- Exerc 3.1 
base_2020 AS (
    SELECT *
    FROM garantia_safra
    WHERE ano_referencia >= 2020
),
 
-- Exerc 3.2 
totais_beneficiario AS (
    SELECT
        sigla_uf,
        id_municipio,
        ano_referencia,
        nis_favorecido,
        nome_favorecido,
        COALESCE(SUM(valor_parcela), 0) AS total_recebido,
        COALESCE(AVG(valor_parcela), 0) AS media_por_parcela,
        COUNT(*)                       AS qtd_parcelas
    FROM base_2020
    GROUP BY sigla_uf, id_municipio, ano_referencia, nis_favorecido, nome_favorecido
),
 
-- Exerc 3.3 
totais_municipio AS (
    SELECT
        sigla_uf,
        id_municipio,
        ano_referencia,
        COALESCE(SUM(valor_parcela), 0) AS total_municipio
    FROM base_2020
    GROUP BY sigla_uf, id_municipio, ano_referencia
),
 
-- Exerc 3.4 
maior_beneficiario_municipio AS (
    SELECT
        sigla_uf,
        id_municipio,
        ano_referencia,
        MAX(total_recebido) AS maior_total_individual
    FROM totais_beneficiario
    GROUP BY sigla_uf, id_municipio, ano_referencia
),
 
-- Exerc 3.5 
faixa_beneficiario AS (
    SELECT
        sigla_uf,
        id_municipio,
        ano_referencia,
        nis_favorecido,
        CASE
            WHEN total_recebido >= 800 THEN 'ALTO'
            WHEN total_recebido >= 500 THEN 'MEDIO'
            ELSE 'BAIXO'
        END AS faixa_valor
    FROM totais_beneficiario
)
 
-- Exerc 3.6 Relatório Final da Parte 3
SELECT
    tb.sigla_uf                                                        AS uf,
    tb.id_municipio                                                    AS municipio,
    tb.ano_referencia                                                  AS ano,
    tb.nis_favorecido                                                  AS nis,
    tb.nome_favorecido                                                 AS nome,
    tb.total_recebido,
    ROUND(tb.media_por_parcela, 2)                                     AS media_por_parcela,
    tb.qtd_parcelas,
    tm.total_municipio,
    ROUND(tb.total_recebido * 100.0 / NULLIF(tm.total_municipio, 0), 2) AS participacao_pct,
    mb.maior_total_individual,
    fb.faixa_valor,
    CASE
        WHEN tb.total_recebido = mb.maior_total_individual THEN 'DESTAQUE_MUNICIPAL'
        ELSE 'OUTROS'
    END AS grupo_destaque
FROM totais_beneficiario tb
JOIN totais_municipio tm
    ON tb.sigla_uf = tm.sigla_uf
   AND tb.id_municipio = tm.id_municipio
   AND tb.ano_referencia = tm.ano_referencia
JOIN maior_beneficiario_municipio mb
    ON tb.sigla_uf = mb.sigla_uf
   AND tb.id_municipio = mb.id_municipio
   AND tb.ano_referencia = mb.ano_referencia
JOIN faixa_beneficiario fb
    ON tb.sigla_uf = fb.sigla_uf
   AND tb.id_municipio = fb.id_municipio
   AND tb.ano_referencia = fb.ano_referencia
   AND tb.nis_favorecido = fb.nis_favorecido
ORDER BY tb.sigla_uf, tb.id_municipio, tb.ano_referencia, tb.total_recebido DESC;