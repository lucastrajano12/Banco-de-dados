# Banco de Dados — Exercícios e Desafios

Repositório com os exercícios e desafios da disciplina de Banco de Dados.

## Estrutura

```
bd/
├── 01_warming_up.sql                                  # UPDATE, DELETE, GROUP BY, agregação
├── warming_up_schema.sql                              # base de dados usada no exercício acima
│
├── 02_exercicios_ctes.sql                              # CTEs (WITH)
│
├── 03_exercicios_inner_join.sql                        # INNER JOIN
├── exercicios_inner_join_schema.sql                    # base usada nos exercícios 03 a 06
│
├── 04_exercicios_left_join.sql                         # LEFT JOIN
│
├── 05_challenge_night_dashboard_executivo.sql          # 15 KPIs - Dashboard Executivo TechVendas
├── Challenge_Night_Dashboard_Executivo_TechVendas.docx # documento de entrega do desafio acima
│
├── 06_challenge_night_ii_joins_avancados.sql           # INNER/LEFT/RIGHT/FULL OUTER JOIN, CTEs
├── clientes_integracao_schema.sql                      # base de apoio (exercícios 12 e 13 do desafio acima)
│
├── 07_missoes_da_noite.sql                             # COALESCE, BETWEEN, IN, LIKE, EXISTS
├── missoes_noite_schema_extra.sql                      # colunas extras (renda, estoque) usadas no arquivo acima
│
├── 08_desafio_final_sportzone.sql                      # Desafio Final do Semestre - SportZone
└── Relatorio_Gerencial_Executivo_SportZone.docx        # documento de entrega do desafio final

php/
└── (em breve)
```

## Como usar

Cada arquivo `.sql` de exercício foi pensado para ser executado depois do respectivo arquivo de schema (quando houver um), que cria as tabelas e insere os dados de teste.
