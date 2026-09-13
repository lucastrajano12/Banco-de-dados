-- ============================================================
-- SCHEMA DE APOIO: INTEGRAÇÃO DE SISTEMAS (Exercícios 12 e 13)
-- Cenário: a TechVendas S/A adquiriu outra empresa e agora precisa
-- comparar as duas bases de clientes para planejar a integração.
--
-- Observação: como o enunciado não forneceu essas tabelas prontas,
-- este schema cria uma base de exemplo para que as consultas dos
-- exercícios 12 e 13 possam ser executadas e testadas.
-- O e-mail é usado como chave de comparação entre as duas bases,
-- já que os IDs internos de cada sistema são diferentes.
-- ============================================================

DROP TABLE IF EXISTS clientes_empresa_adquirida;
DROP TABLE IF EXISTS clientes_techvendas;

CREATE TABLE clientes_techvendas (
    id_cliente      INTEGER       PRIMARY KEY,
    nome_cliente    VARCHAR(100)  NOT NULL,
    email           VARCHAR(120)  NOT NULL
);

CREATE TABLE clientes_empresa_adquirida (
    id_cliente      INTEGER       PRIMARY KEY,
    nome_cliente    VARCHAR(100)  NOT NULL,
    email           VARCHAR(120)  NOT NULL
);

-- 10 clientes da base já existente da TechVendas
INSERT INTO clientes_techvendas (id_cliente, nome_cliente, email) VALUES
    (1, 'Ana Souza', 'ana.souza@email.com'),
    (2, 'Bruno Lima', 'bruno.lima@email.com'),
    (3, 'Carla Mendes', 'carla.mendes@email.com'),
    (4, 'Diego Martins', 'diego.martins@email.com'),
    (5, 'Eduarda Alves', 'eduarda.alves@email.com'),
    (6, 'Felipe Rocha', 'felipe.rocha@email.com'),
    (7, 'Gabriela Costa', 'gabriela.costa@email.com'),
    (8, 'Henrique Silva', 'henrique.silva@email.com'),
    (9, 'Isabela Nunes', 'isabela.nunes@email.com'),
    (10, 'João Ribeiro', 'joao.ribeiro@email.com');

-- 10 clientes da base da empresa recém-adquirida
-- (5 já eram clientes da TechVendas, 5 são totalmente novos)
INSERT INTO clientes_empresa_adquirida (id_cliente, nome_cliente, email) VALUES
    (101, 'Ana Souza', 'ana.souza@email.com'),
    (102, 'Bruno Lima', 'bruno.lima@email.com'),
    (103, 'Marcos Vidal', 'marcos.vidal@email.com'),
    (104, 'Patrícia Nogueira', 'patricia.nogueira@email.com'),
    (105, 'Carla Mendes', 'carla.mendes@email.com'),
    (106, 'Rafael Duarte', 'rafael.duarte@email.com'),
    (107, 'Diego Martins', 'diego.martins@email.com'),
    (108, 'Vitor Hugo', 'vitor.hugo@email.com'),
    (109, 'Eduarda Alves', 'eduarda.alves@email.com'),
    (110, 'Camila Reis', 'camila.reis@email.com');
