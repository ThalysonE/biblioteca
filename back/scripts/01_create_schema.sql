-- Criação do scheme caso não exista! :)
-- Há duas formas de usar o banco de dados criando um schema ou um banco separado, escolha o que mais for fácil para você
-- USANDO SCHEMA:
DROP SCHEMA biblioteca CASCADE; -- (Cuidado ao usar esse comando)
CREATE SCHEMA biblioteca; -- CASO QUEIRA USAR UM SCHEMA (MAIS FÁCIL, só que pode causar erros caso você possua outros schemas no mesmo banco com tabelas com o mesmo nome das utilizadas nesse script)
SET search_path TO biblioteca; -- Usado somente se você escolher criar um schema

-- CRIANDO BANCO:
--DROP DATABASE biblioteca; -- APAGA O BANCO EXISTENTE
--CREATE DATABASE biblioteca; -- CASO QUEIRA USAR UM BANCO SEPARADO (RECOMENDADO, pois evita conflitos com outros schemas e melhora o isolamento, mas é necessário adicionar o banco ao DBeaver)

DROP TABLE IF EXISTS detalhe_emprestimo;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS turma;
DROP TABLE IF EXISTS serie;
DROP TABLE IF EXISTS turno;
DROP TABLE IF EXISTS exemplar_livro;
DROP TABLE IF EXISTS livro_categoria;
DROP TABLE IF EXISTS livro_subcategoria;
DROP TABLE IF EXISTS subcategoria;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS autor;
DROP TABLE IF EXISTS pais;

CREATE TABLE IF NOT EXISTS turno(
	id_turno SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_turno)
);

CREATE TABLE IF NOT EXISTS serie(
	id_serie SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_serie)
);

CREATE TABLE IF NOT EXISTS turma(
	id_turma SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	serie INT NOT NULL,
	turno INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_turma),
	UNIQUE(descricao, serie, turno),
	FOREIGN KEY(serie) REFERENCES serie(id_serie),
	FOREIGN KEY(turno) REFERENCES turno(id_turno)
);

CREATE TABLE IF NOT EXISTS pais (
	id_pais SMALLINT NOT NULL,
	nome VARCHAR(255) NOT NULL UNIQUE,
	sigla VARCHAR(3) NOT NULL,
	ativo BOOLEAN NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_pais)
);

CREATE TABLE IF NOT EXISTS autor(
	id_autor SERIAL NOT NULL,
	nome VARCHAR(255) NOT NULL UNIQUE,
	nacionalidade SMALLINT,
	sexo CHAR,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_autor),
	FOREIGN KEY(nacionalidade) REFERENCES pais(id_pais) 
);

CREATE TABLE IF NOT EXISTS livro(
	id_livro SERIAL NOT NULL,
	isbn VARCHAR(13) NOT NULL UNIQUE,
	titulo VARCHAR(255) NOT NULL,
	ano_publicacao int,
	editora VARCHAR(255),
	pais SMALLINT,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro),
	FOREIGN KEY(pais) REFERENCES pais(id_pais)
);


CREATE TABLE IF NOT EXISTS livro_autor(
	id_livro INT NOT NULL,
	id_autor INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_autor),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_autor) REFERENCES autor(id_autor)
);


CREATE TABLE IF NOT EXISTS categoria (
	id_categoria SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	ativo BOOLEAN default true,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_categoria)
);

CREATE TABLE IF NOT EXISTS subcategoria (
	id_subcategoria SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	ativo BOOLEAN NOT NULL DEFAULT TRUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_subcategoria)
);

CREATE TABLE IF NOT EXISTS livro_subcategoria (
	id_livro INT NOT NULL,
	id_subcategoria INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_subcategoria),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_subcategoria) REFERENCES subcategoria(id_subcategoria)
);

CREATE TABLE IF NOT EXISTS livro_categoria (
	id_livro INT NOT NULL,
	id_categoria INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_categoria),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE IF NOT EXISTS exemplar_livro (
	id_exemplar_livro SERIAL NOT NULL,
	livro INT NOT NULL,
	cativo BOOLEAN NOT NULL,
	status SMALLINT DEFAULT 1 NOT NULL,
	estado SMALLINT DEFAULT 1 NOT NULL,
	ativo  BOOLEAN NOT NULL DEFAULT TRUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_exemplar_livro),
	FOREIGN KEY(livro) REFERENCES livro(id_livro) 
);

CREATE TABLE IF NOT EXISTS usuario (
	id_usuario SERIAL NOT NULL,
	login VARCHAR(255) NOT NULL UNIQUE,
	cpf VARCHAR(12),
	nome VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	telefone VARCHAR(11),
	data_nascimento DATE,
	senha VARCHAR(255) NOT NULL,
	permissoes BIGINT NOT NULL,
	ativo BOOLEAN NOT NULL DEFAULT TRUE,
	turma INT DEFAULT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_usuario),
	FOREIGN KEY(turma) REFERENCES turma(id_turma)
);

CREATE TABLE IF NOT EXISTS emprestimo (
	id_emprestimo SERIAL NOT null,
	exemplar_livro INT NOT NULL,
	usuario INT NOT NULL, -- Esse usuário é o aluno que pede o livro
	data_emprestimo DATE NOT NULL,
	num_renovacoes smallint DEFAULT 0,
	data_prevista_devolucao DATE NOT NULL,
	data_devolucao DATE DEFAULT NULL,
	status smallint DEFAULT 1,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_emprestimo),
	FOREIGN KEY(exemplar_livro) REFERENCES exemplar_livro(id_exemplar_livro),
	FOREIGN KEY(usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE IF NOT EXISTS detalhe_emprestimo (
	id_detalhe_emprestimo SERIAL NOT NULL,
	usuario INT NOT NULL, -- Esse é o usuário do sistema que realiza o empréstimo
	emprestimo INT NOT NULL,
	data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	acao SMALLINT NOT NULL,
	detalhe VARCHAR(255),
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	observacao VARCHAR(255),
	primary key(id_detalhe_emprestimo),
	foreign key (usuario) references usuario(id_usuario),
	foreign key (emprestimo) references emprestimo(id_emprestimo)
);

-- Tabela pais
INSERT INTO pais (id_pais, nome, sigla, ativo) VALUES
(1, 'Afeganistão', 'AFG', TRUE),
(2, 'África do Sul', 'ZAF', TRUE),
(3, 'Albânia', 'ALB', TRUE),
(4, 'Alemanha', 'DEU', TRUE),
(5, 'Andorra', 'AND', TRUE),
(6, 'Angola', 'AGO', TRUE),
(7, 'Anguilla', 'AIA', TRUE),
(8, 'Antígua e Barbuda', 'ATG', TRUE),
(9, 'Arábia Saudita', 'SAU', TRUE),
(10, 'Argélia', 'DZA', TRUE),
(11, 'Argentina', 'ARG', TRUE),
(12, 'Armênia', 'ARM', TRUE),
(13, 'Aruba', 'ABW', TRUE),
(14, 'Austrália', 'AUS', TRUE),
(15, 'Áustria', 'AUT', TRUE),
(16, 'Azerbaijão', 'AZE', TRUE),
(17, 'Bahamas', 'BHS', TRUE),
(18, 'Bangladesh', 'BGD', TRUE),
(19, 'Barbados', 'BRB', TRUE),
(20, 'Barein', 'BHR', TRUE),
(21, 'Bélgica', 'BEL', TRUE),
(22, 'Belize', 'BLZ', TRUE),
(23, 'Benin', 'BEN', TRUE),
(24, 'Bermuda', 'BMU', TRUE),
(25, 'Bielorússia', 'BLR', TRUE),
(26, 'Bolívia', 'BOL', TRUE),
(27, 'Bonaire, Santo Eustáquio e Saba', 'BES', TRUE),
(28, 'Bósnia-Herzegovina', 'BIH', TRUE),
(29, 'Botsuana', 'BWA', TRUE),
(30, 'Brasil', 'BRA', TRUE),
(31, 'Brunei', 'BRN', TRUE),
(32, 'Bulgária', 'BGR', TRUE),
(33, 'Burkina Faso', 'BFA', TRUE),
(34, 'Burundi', 'BDI', TRUE),
(35, 'Butão', 'BTN', TRUE),
(36, 'Cabo Verde', 'CPV', TRUE),
(37, 'Camarões', 'CMR', TRUE),
(38, 'Camboja', 'KHM', TRUE),
(39, 'Canadá', 'CAN', TRUE),
(40, 'Casaquistão', 'KAZ', TRUE),
(41, 'Catar', 'QAT', TRUE),
(42, 'Chade', 'TCD', TRUE),
(43, 'Chile', 'CHL', TRUE),
(44, 'China', 'CHN', TRUE),
(45, 'China, Hong Kong', 'HKG', TRUE),
(46, 'China, Macao', 'MAC', TRUE),
(47, 'Chipre', 'CYP', TRUE),
(48, 'Cingapura', 'SGP', TRUE),
(49, 'Colômbia', 'COL', TRUE),
(50, 'Comores', 'COM', TRUE),
(51, 'Congo', 'COG', TRUE),
(52, 'Coréia do Norte', 'PRK', TRUE),
(53, 'Coréia do Sul', 'KOR', TRUE),
(54, 'Costa do Marfim', 'CIV', TRUE),
(55, 'Costa Rica', 'CRI', TRUE),
(56, 'Croácia', 'HRV', TRUE),
(57, 'Cuba', 'CUB', TRUE),
(58, 'Curaçao', 'CUW', TRUE),
(59, 'Dinamarca', 'DNK', TRUE),
(60, 'Djibouti', 'DJI', TRUE),
(61, 'Dominica', 'DMA', TRUE),
(62, 'Egito', 'EGY', TRUE),
(63, 'El Salvador', 'SLV', TRUE),
(64, 'Emirados Árabes Unidos', 'ARE', TRUE),
(65, 'Equador', 'ECU', TRUE),
(66, 'Eritréia', 'ERI', TRUE),
(67, 'Eslováquia', 'SVK', TRUE),
(68, 'Eslovênia', 'SVN', TRUE),
(69, 'Espanha', 'ESP', TRUE),
(70, 'Estados Unidos da América', 'USA', TRUE),
(71, 'Estônia', 'EST', TRUE),
(72, 'Etiópia', 'ETH', TRUE),
(73, 'Fiji', 'FJI', TRUE),
(74, 'Filipinas', 'PHL', TRUE),
(75, 'Finlândia', 'FIN', TRUE),
(76, 'França', 'FRA', TRUE),
(77, 'Gabão', 'GAB', TRUE),
(78, 'Gâmbia', 'GMB', TRUE),
(79, 'Gana', 'GHA', TRUE),
(80, 'Geórgia', 'GEO', TRUE),
(81, 'Gibraltar', 'GIB', TRUE),
(82, 'Granada', 'GRD', TRUE),
(83, 'Grécia', 'GRC', TRUE),
(84, 'Groenlândia', 'GRL', TRUE),
(85, 'Guam', 'GUM', TRUE),
(86, 'Guatemala', 'GTM', TRUE),
(87, 'Guernsey', 'GGY', TRUE),
(88, 'Guiana', 'GUY', TRUE),
(89, 'Guiana Francesa', 'GUF', TRUE),
(90, 'Guiné', 'GIN', TRUE),
(91, 'Guiné Equatorial', 'GNQ', TRUE),
(92, 'Guiné-Bissau', 'GNB', TRUE),
(93, 'Haiti', 'HTI', TRUE),
(94, 'Holanda', 'NLD', TRUE),
(95, 'Honduras', 'HND', TRUE),
(96, 'Hungria', 'HUN', TRUE),
(97, 'Iêmen', 'YEM', TRUE),
(98, 'Ilha de Man', 'IMN', TRUE),
(99, 'Ilha Guadalupe', 'GLP', TRUE),
(100, 'Ilha Norfolk', 'NFK', TRUE),
(101, 'Ilha Reunião', 'REU', TRUE),
(102, 'Ilhas Alanda', 'ALA', TRUE),
(103, 'Ilhas Cayman', 'CYM', TRUE),
(104, 'Ilhas Cook', 'COK', TRUE),
(105, 'Ilhas do Canal', 'nan', TRUE),
(106, 'Ilhas Faeroe', 'FRO', TRUE),
(107, 'Ilhas Falkland', 'FLK', TRUE),
(108, 'Ilhas Marianas', 'MNP', TRUE),
(109, 'Ilhas Marshall', 'MHL', TRUE),
(110, 'Ilhas Salomão', 'SLB', TRUE),
(111, 'Ilhas Turks e Caicos', 'TCA', TRUE),
(112, 'Ilhas Virgens', 'VIR', TRUE),
(113, 'Ilhas Virgens Britânicas', 'VGB', TRUE),
(114, 'Ilhas Wallis e Futuna', 'WLF', TRUE),
(115, 'Índia', 'IND', TRUE),
(116, 'Indonésia', 'IDN', TRUE),
(117, 'Irã', 'IRN', TRUE),
(118, 'Iraque', 'IRQ', TRUE),
(119, 'Irlanda', 'IRL', TRUE),
(120, 'Islândia', 'ISL', TRUE),
(121, 'Israel', 'ISR', TRUE),
(122, 'Itália', 'ITA', TRUE),
(123, 'Jamaica', 'JAM', TRUE),
(124, 'Japão', 'JPN', TRUE),
(125, 'Jersey', 'JEY', TRUE),
(126, 'Jordânia', 'JOR', TRUE),
(127, 'Kiribati', 'KIR', TRUE),
(128, 'Kuwait', 'KWT', TRUE),
(129, 'Laos', 'LAO', TRUE),
(130, 'Lesoto', 'LSO', TRUE),
(131, 'Letônia', 'LVA', TRUE),
(132, 'Líbano', 'LBN', TRUE),
(133, 'Libéria', 'LBR', TRUE),
(134, 'Líbia', 'LBY', TRUE),
(135, 'Liechtenstein', 'LIE', TRUE),
(136, 'Lituânia', 'LTU', TRUE),
(137, 'Luxemburgo', 'LUX', TRUE),
(138, 'Macedônia', 'MKD', TRUE),
(139, 'Madagáscar', 'MDG', TRUE),
(140, 'Malásia', 'MYS', TRUE),
(141, 'Malauí', 'MWI', TRUE),
(142, 'Maldivas', 'MDV', TRUE),
(143, 'Mali', 'MLI', TRUE),
(144, 'Malta', 'MLT', TRUE),
(145, 'Marrocos', 'MAR', TRUE),
(146, 'Martinica', 'MTQ', TRUE),
(147, 'Maurício', 'MUS', TRUE),
(148, 'Mauritânia', 'MRT', TRUE),
(149, 'Mayotte', 'MYT', TRUE),
(150, 'México', 'MEX', TRUE),
(151, 'Mianma', 'MMR', TRUE),
(152, 'Micronésia', 'FSM', TRUE),
(153, 'Moçambique', 'MOZ', TRUE),
(154, 'Moldávia', 'MDA', TRUE),
(155, 'Mônaco', 'MCO', TRUE),
(156, 'Mongólia', 'MNG', TRUE),
(157, 'Montenegro', 'MNE', TRUE),
(158, 'Montserrat', 'MSR', TRUE),
(159, 'Namíbia', 'NAM', TRUE),
(160, 'Nauru', 'NRU', TRUE),
(161, 'Nepal', 'NPL', TRUE),
(162, 'Nicarágua', 'NIC', TRUE),
(163, 'Níger', 'NER', TRUE),
(164, 'Nigéria', 'NGA', TRUE),
(165, 'Niue', 'NIU', TRUE),
(166, 'Noruega', 'NOR', TRUE),
(167, 'Nova Caledônia', 'NCL', TRUE),
(168, 'Nova Zelândia', 'NZL', TRUE),
(169, 'Omã', 'OMN', TRUE),
(170, 'Palau', 'PLW', TRUE),
(171, 'Palestina', 'PSE', TRUE),
(172, 'Panamá', 'PAN', TRUE),
(173, 'Papua Nova Guiné', 'PNG', TRUE),
(174, 'Paquistão', 'PAK', TRUE),
(175, 'Paraguai', 'PRY', TRUE),
(176, 'Peru', 'PER', TRUE),
(177, 'Pitcairn', 'PCN', TRUE),
(178, 'Polinésia Francesa', 'PYF', TRUE),
(179, 'Polônia', 'POL', TRUE),
(180, 'Porto Rico', 'PRI', TRUE),
(181, 'Portugal', 'PRT', TRUE),
(182, 'Quênia', 'KEN', TRUE),
(183, 'Quirguistão', 'KGZ', TRUE),
(184, 'Reino Unido', 'GBR', TRUE),
(185, 'República Centro Africana', 'CAF', TRUE),
(186, 'República Democrática do Congo', 'COD', TRUE),
(187, 'República Dominicana', 'DOM', TRUE),
(188, 'República Tcheca', 'CZE', TRUE),
(189, 'Romênia', 'ROU', TRUE),
(190, 'Ruanda', 'RWA', TRUE),
(191, 'Rússia (Federação Russa)', 'RUS', TRUE),
(192, 'Saara Ocidental', 'ESH', TRUE),
(193, 'Saint Martin (parte francesa)', 'MAF', TRUE),
(194, 'Saint Martin (parte holandesa)', 'SXM', TRUE),
(195, 'Saint Pierre e Miquelon', 'SPM', TRUE),
(196, 'Samoa', 'WSM', TRUE),
(197, 'Samoa Americana', 'ASM', TRUE),
(198, 'San Marino', 'SMR', TRUE),
(199, 'Santa Helena', 'SHN', TRUE),
(200, 'Santa Lúcia', 'LCA', TRUE),
(201, 'São Bartolomeu', 'BLM', TRUE),
(202, 'São Cristóvão e Nevis', 'KNA', TRUE),
(203, 'São Tome e Príncipe', 'STP', TRUE),
(204, 'São Vicente e Granadinas', 'VCT', TRUE),
(205, 'Sark', ' ', TRUE),
(206, 'Seichelles', 'SYC', TRUE),
(207, 'Senegal', 'SEN', TRUE),
(208, 'Serra Leoa', 'SLE', TRUE),
(209, 'Sérvia', 'SRB', TRUE),
(210, 'Síria', 'SYR', TRUE),
(211, 'Somália', 'SOM', TRUE),
(212, 'Sri Lanka', 'LKA', TRUE),
(213, 'Suazilândia', 'SWZ', TRUE),
(214, 'Sudão do Sul', 'SSD', TRUE),
(215, 'Sudão', 'SDN', TRUE),
(216, 'Suécia', 'SWE', TRUE),
(217, 'Suíça', 'CHE', TRUE),
(218, 'Suriname', 'SUR', TRUE),
(219, 'Svalbard e Jan Mayen Islands', 'SJM', TRUE),
(220, 'Tadjiquistão', 'TJK', TRUE),
(221, 'Tailândia', 'THA', TRUE),
(222, 'Tanzânia', 'TZA', TRUE),
(223, 'Timor Leste', 'TLS', TRUE),
(224, 'Togo', 'TGO', TRUE),
(225, 'Tokelau', 'TKL', TRUE),
(226, 'Tonga', 'TON', TRUE),
(227, 'Trinidad e Tobago', 'TTO', TRUE),
(228, 'Tunísia', 'TUN', TRUE),
(229, 'Turcomenistão', 'TKM', TRUE),
(230, 'Turquia', 'TUR', TRUE),
(231, 'Tuvalu', 'TUV', TRUE),
(232, 'Ucrânia', 'UKR', TRUE),
(233, 'Uganda', 'UGA', TRUE),
(234, 'Uruguai', 'URY', TRUE),
(235, 'Uzbequistão', 'UZB', TRUE),
(236, 'Vanuatu', 'VUT', TRUE),
(237, 'Vaticano', 'VAT', TRUE),
(238, 'Venezuela', 'VEN', TRUE),
(239, 'Vietnã', 'VNM', TRUE),
(240, 'Zâmbia', 'ZMB', TRUE),
(241, 'Zimbábue', 'ZWE', TRUE);

INSERT INTO turno (id_turno, descricao) VALUES
(1, 'Manhã'),
(2, 'Tarde'),
(3, 'Noite'),
(4, 'Integral');

INSERT INTO serie (id_serie, descricao) VALUES
(1, '1º Ano'),
(2, '2º Ano'),
(3, '3º Ano');

INSERT INTO usuario (login, cpf, nome, email, telefone, data_nascimento, senha, permissoes) VALUES
('admin','21747274046', 'Admin User', 'admin@biblioteca.com', '11123456789', '1990-01-01', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3',  16383);