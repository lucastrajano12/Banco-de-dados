use prova_1

select * from garantia_safra;



 WITH
-- Exerc 2.1
base_2020 AS (
    SELECT *
    FROM garantia_safra
    WHERE ano_referencia = 2020
),
 
-- Exerc 2.2
valor_uf AS (
    SELECT
        sigla_uf,
        COALESCE(SUM(valor_parcela), 0) AS valor_uf,
        COUNT(*)                       AS qtd_parcelas
    FROM base_2020
    GROUP BY sigla_uf
),
 
-- Exerc 2.3 
beneficiarios_uf AS (
    SELECT
        sigla_uf,
        COUNT(DISTINCT nis_favorecido) AS beneficiarios
    FROM base_2020
    GROUP BY sigla_uf
),
 
-- Exerc 2.4 
municipios_uf AS (
    SELECT
        sigla_uf,
        COUNT(DISTINCT id_municipio) AS municipios
    FROM base_2020
    GROUP BY sigla_uf
),
 
-- Exerc 2.5
total_brasil AS (
    SELECT COALESCE(SUM(valor_parcela), 0) AS total_brasil
    FROM base_2020
),
 
-- Exerc 2.6 
faixa_uf AS (
    SELECT
        sigla_uf,
        valor_uf,
        CASE
            WHEN valor_uf >= 20000 THEN 'ALTO'
            WHEN valor_uf >= 10000 THEN 'MEDIO'
            ELSE 'BAIXO'
        END AS faixa
    FROM valor_uf
),
 
-- Exerc 2.7 
top5_uf AS (
    SELECT sigla_uf, valor_uf
    FROM valor_uf
    ORDER BY valor_uf DESC
    LIMIT 5
)
 
-- Exerc 2.8 Relatório Final Da Parte 2 (Top 5 em 2020) 
SELECT
    t.sigla_uf,
    v.valor_uf                                         AS valor_total,
    v.qtd_parcelas,
    b.beneficiarios,
    m.municipios,
    ROUND(v.valor_uf * 100.0 / NULLIF(tb.total_brasil, 0), 2) AS participacao_pct,
    f.faixa,
    CASE
        WHEN v.valor_uf = (SELECT MAX(valor_uf) FROM top5_uf) THEN 'LIDER_BR'
        ELSE 'TOP_5'
    END AS grupo_destaque
FROM top5_uf t
JOIN valor_uf v         ON t.sigla_uf = v.sigla_uf
JOIN beneficiarios_uf b ON t.sigla_uf = b.sigla_uf
JOIN municipios_uf m    ON t.sigla_uf = m.sigla_uf
JOIN faixa_uf f         ON t.sigla_uf = f.sigla_uf
CROSS JOIN total_brasil tb
ORDER BY v.valor_uf DESC;