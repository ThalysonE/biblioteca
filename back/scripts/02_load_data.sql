

SET search_path TO biblioteca; -- Usado somente se você escolher criar um schema

-- Tabela autor
INSERT INTO autor (nome, nacionalidade, sexo) VALUES
('Machado de Assis', 30, 'M'), -- Brasil (id 30)
('J.K. Rowling', 184, 'F'), -- Reino Unido (id 184)
('George R. R. Martin', 70, 'M'), -- EUA (id 70)
('Clarice Lispector', 30, 'F'), -- Brasil (id 30)
('José Saramago', 181, 'M'), -- Portugal (id 181)
('Agatha Christie', 184, 'F'), -- Reino Unido (id 184)
('Gabriel García Márquez', 49, 'M'), -- Colômbia (id 49)
('Stephen King', 70, 'M'), -- EUA (id 70)
('Edgar Allan Poe', 70, 'M'), -- EUA (id 70)
('Virginia Woolf', 184, 'F'), -- Reino Unido (id 184)
('Ernest Hemingway', 70, 'M'), -- EUA (id 70)
('William Shakespeare', 184, 'M'), -- Reino Unido (id 184)
('Jane Austen', 184, 'F'), -- Reino Unido (id 184)
('Jules Verne', 76, 'M'), -- França (id 76)
('Franz Kafka', 56, 'M'), -- Croácia (id 56)
('George Orwell', 184, 'M'), -- Reino Unido (id 184)
('Fyodor Dostoevsky', 191, 'M'), -- Rússia (id 191)
('H.P. Lovecraft', 70, 'M'), -- EUA (id 70)
('Isaac Asimov', 70, 'M'), -- EUA (id 70)
('Mary Shelley', 184, 'F'), -- Reino Unido (id 184)
('Herman Melville', 70, 'M'), -- EUA (id 70)
('Lewis Carroll', 184, 'M'), -- Reino Unido (id 184)
('Tolkien', 184, 'M'); -- Reino Unido (id 184)


-- Tabela livro
INSERT INTO livro (isbn, titulo, ano_publicacao, editora, pais) VALUES
('9781234567897', 'Dom Casmurro', '1899', 'Editora X', 30), -- Brasil
('9780747532743', 'Harry Potter e a Pedra Filosofal', '1997', 'Bloomsbury', 184), -- Reino Unido
('9780553103540', 'A Game of Thrones', '1996', 'Bantam Books', 70), -- EUA
('9788575427583', 'A Hora da Estrela', '1977', 'Rocco', 30), -- Brasil
('9788535914849', 'Ensaio Sobre a Cegueira', '1995', 'Companhia das Letras', 181), -- Portugal
('9780062073488', 'Assassinato no Expresso do Oriente', '1934', 'HarperCollins', 184), -- Reino Unido
('9788437604947', 'Cem Anos de Solidão', '1967', 'Sudamericana', 49), -- Colômbia
('9780451169518', 'O Iluminado', '1977', 'Doubleday', 70), -- EUA
('9780486297442', 'O Corvo', '1845', 'Fall River Press', 70), -- EUA
('9780156035234', 'Mrs. Dalloway', '1925', 'Harcourt', 184), -- Reino Unido
('9780684801223', 'O Velho e o Mar', '1952', 'Scribner', 70), -- EUA
('9780743477109', 'Hamlet', '1603', 'Simon & Schuster', 184), -- Reino Unido
('9780141439587', 'Orgulho e Preconceito', '1813', 'Penguin', 184), -- Reino Unido
('9780553213973', '20.000 Léguas Submarinas', '1870', 'Signet', 76), -- França
('9780805209990', 'A Metamorfose', '1915', 'Schocken', 56), -- Croácia
('9780451524935', '1984', '1949', 'Secker & Warburg', 184), -- Reino Unido
('9780679734505', 'Crime e Castigo', '1866', 'Vintage', 191), -- Rússia
('9780345325815', 'O Chamado de Cthulhu', '1928', 'Arkham House', 70), -- EUA
('9780553293357', 'Eu, Robô', '1950', 'Spectra', 70), -- EUA
('9780141439471', 'Frankenstein', '1818', 'Penguin', 184), -- Reino Unido
('9780142437179', 'Moby Dick', '1851', 'Harper & Brothers', 70), -- EUA
('9780192803365', 'Alice no País das Maravilhas', '1865', 'Macmillan', 184), -- Reino Unido
('9780261103283', 'O Senhor dos Anéis', '1954', 'Allen & Unwin', 184); -- Reino Unido


-- Tabela livro_autor
INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1, 1),  -- Dom Casmurro por Machado de Assis
(2, 2),  -- Harry Potter por J.K. Rowling
(3, 3),  -- A Game of Thrones por George R. R. Martin
(4, 4),  -- A Hora da Estrela por Clarice Lispector
(5, 5),  -- Ensaio Sobre a Cegueira por José Saramago
(6, 6),  -- Assassinato no Expresso do Oriente por Agatha Christie
(7, 7),  -- Cem Anos de Solidão por Gabriel García Márquez
(8, 8),  -- O Iluminado por Stephen King
(9, 9),  -- O Corvo por Edgar Allan Poe
(10, 10), -- Mrs. Dalloway por Virginia Woolf
(11, 11), -- O Velho e o Mar por Ernest Hemingway
(12, 12), -- Hamlet por William Shakespeare
(13, 13), -- Orgulho e Preconceito por Jane Austen
(14, 14), -- 20.000 Léguas Submarinas por Jules Verne
(15, 15), -- A Metamorfose por Franz Kafka
(16, 16), -- 1984 por George Orwell
(17, 17), -- Crime e Castigo por Fyodor Dostoevsky
(18, 18), -- O Chamado de Cthulhu por H.P. Lovecraft
(19, 19), -- Eu, Robô por Isaac Asimov
(20, 20), -- Frankenstein por Mary Shelley
(21, 21), -- Moby Dick por Herman Melville
(22, 22), -- Alice no País das Maravilhas por Lewis Carroll
(23, 23); -- O Senhor dos Anéis por J.R.R. Tolkien

-- Tabela exemplar_livro
INSERT INTO exemplar_livro (id_exemplar_livro, livro, cativo, status, estado) VALUES
(1, 1, FALSE, 1, 1),  -- Exemplar de Dom Casmurro
(2, 2, TRUE, 1, 2),   -- Exemplar de Harry Potter
(3, 3, FALSE, 2, 2),  -- Exemplar de A Game of Thrones
(4, 4, FALSE, 1, 1),  -- Exemplar de A Hora da Estrela
(5, 5, TRUE, 1, 2),   -- Exemplar de Ensaio Sobre a Cegueira
(6, 6, FALSE, 1, 1),  -- Exemplar de Assassinato no Expresso do Oriente
(7, 7, TRUE, 2, 2),   -- Exemplar de Cem Anos de Solidão
(8, 8, FALSE, 1, 1),  -- Exemplar de O Iluminado
(9, 9, TRUE, 1, 2),   -- Exemplar de O Corvo
(10, 10, FALSE, 2, 2), -- Exemplar de Mrs. Dalloway
(11, 11, TRUE, 1, 1), -- Exemplar de O Velho e o Mar
(12, 12, FALSE, 1, 2), -- Exemplar de Hamlet
(13, 13, TRUE, 2, 1), -- Exemplar de Orgulho e Preconceito
(14, 14, FALSE, 1, 1), -- Exemplar de 20.000 Léguas Submarinas
(15, 15, TRUE, 1, 2), -- Exemplar de A Metamorfose
(16, 16, FALSE, 2, 1), -- Exemplar de 1984
(17, 17, TRUE, 1, 2), -- Exemplar de Crime e Castigo
(18, 18, FALSE, 1, 1), -- Exemplar de O Chamado de Cthulhu
(19, 19, TRUE, 2, 2), -- Exemplar de Eu, Robô
(20, 20, FALSE, 1, 1), -- Exemplar de Frankenstein
(21, 21, TRUE, 1, 2), -- Exemplar de Moby Dick
(22, 22, FALSE, 2, 1), -- Exemplar de Alice no País das Maravilhas
(23, 23, TRUE, 1, 2); -- Exemplar de O Senhor dos Anéis

-- Poque as vezes o postgres ferra a sequência do serial
-- estou colacando a sequencia para avançar mais um apartir do max(id)
-- eu sei isso já deveria ser automático, mas eu deu pal no meu pc. :(
select setval((select pg_get_serial_sequence('exemplar_livro', 'id_exemplar_livro')), (select max(id_exemplar_livro) from exemplar_livro) + 1);

INSERT INTO categoria (descricao) VALUES
('Romance'),
('Fantasia'),
('Ficção Científica'),
('Terror'),
('Clássico'),
('Drama'),
('Poesia');

INSERT INTO livro_categoria (id_livro, id_categoria) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 6),
(5, 6),
(6, 4),
(7, 1),
(8, 4),
(9, 7),
(10, 6),
(11, 5),
(12, 5),
(13, 1),
(14, 3),
(15, 5),
(16, 3),
(17, 5),
(18, 4),
(19, 3),
(20, 4),
(21, 5),
(22, 2),
(23, 2);

INSERT INTO turma (descricao, serie, turno) VALUES
  -- Edificações
  ('Edificações', 1, 1),
  ('Edificações', 1, 2),
  ('Edificações', 1, 3),
  ('Edificações', 1, 4),
  ('Edificações', 2, 1),
  ('Edificações', 2, 2),
  ('Edificações', 2, 3),
  ('Edificações', 2, 4),
  ('Edificações', 3, 1),
  ('Edificações', 3, 2),
  ('Edificações', 3, 3),
  ('Edificações', 3, 4),

  -- Informática
  ('Informática', 1, 1),
  ('Informática', 1, 2),
  ('Informática', 1, 3),
  ('Informática', 1, 4),
  ('Informática', 2, 1),
  ('Informática', 2, 2),
  ('Informática', 2, 3),
  ('Informática', 2, 4),
  ('Informática', 3, 1),
  ('Informática', 3, 2),
  ('Informática', 3, 3),
  ('Informática', 3, 4),

  -- Eletrotécnica
  ('Eletrotécnica', 1, 1),
  ('Eletrotécnica', 1, 2),
  ('Eletrotécnica', 1, 3),
  ('Eletrotécnica', 1, 4),
  ('Eletrotécnica', 2, 1),
  ('Eletrotécnica', 2, 2),
  ('Eletrotécnica', 2, 3),
  ('Eletrotécnica', 2, 4),
  ('Eletrotécnica', 3, 1),
  ('Eletrotécnica', 3, 2),
  ('Eletrotécnica', 3, 3),
  ('Eletrotécnica', 3, 4),

  -- Análises Clínicas
  ('Análises Clínicas', 1, 1),
  ('Análises Clínicas', 1, 2),
  ('Análises Clínicas', 1, 3),
  ('Análises Clínicas', 1, 4),
  ('Análises Clínicas', 2, 1),
  ('Análises Clínicas', 2, 2),
  ('Análises Clínicas', 2, 3),
  ('Análises Clínicas', 2, 4),
  ('Análises Clínicas', 3, 1),
  ('Análises Clínicas', 3, 2),
  ('Análises Clínicas', 3, 3),
  ('Análises Clínicas', 3, 4),

  -- Pesca
  ('Pesca', 1, 1),
  ('Pesca', 1, 2),
  ('Pesca', 1, 3),
  ('Pesca', 1, 4),
  ('Pesca', 2, 1),
  ('Pesca', 2, 2),
  ('Pesca', 2, 3),
  ('Pesca', 2, 4),
  ('Pesca', 3, 1),
  ('Pesca', 3, 2),
  ('Pesca', 3, 3),
  ('Pesca', 3, 4);


 INSERT INTO usuario (login, cpf, nome, email, telefone, data_nascimento, senha, permissoes, turma) VALUES
-- Turmas 1 a 60 (usuários com turma atribuída)
('user1', '11111111111', 'Alice Silva', 'alice.silva@biblioteca.com', '11911111111', '2001-05-12', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 1),
('user2', '22222222222', 'Bruno Costa', 'bruno.costa@biblioteca.com', '11922222222', '2000-08-23', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 2),
('user3', '33333333333', 'Carla Oliveira', 'carla.oliveira@biblioteca.com', '11933333333', '1999-02-15', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 3),
('user4', '44444444444', 'Daniel Souza', 'daniel.souza@biblioteca.com', '11944444444', '2002-09-30', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 4),
('user5', '55555555555', 'Eduarda Lima', 'eduarda.lima@biblioteca.com', '11955555555', '2001-07-18', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 5),
('user6', '66666666666', 'Felipe Martins', 'felipe.martins@biblioteca.com', '11966666666', '2000-11-05', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 6),
('user7', '77777777777', 'Gabriela Almeida', 'gabriela.almeida@biblioteca.com', '11977777777', '2003-03-22', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 7),
('user8', '88888888888', 'Henrique Barbosa', 'henrique.barbosa@biblioteca.com', '11988888888', '2002-12-01', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 8),
('user9', '99999999999', 'Isabela Rocha', 'isabela.rocha@biblioteca.com', '11999999999', '2001-06-14', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 9),
('user10', '10101010101', 'João Mendes', 'joao.mendes@biblioteca.com', '11910101010', '2000-04-09', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 10),

('user11', '12121212121', 'Karen Fernandes', 'karen.fernandes@biblioteca.com', '11912121212', '2001-01-20', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 11),
('user12', '13131313131', 'Leonardo Gomes', 'leonardo.gomes@biblioteca.com', '11913131313', '2002-02-28', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 12),
('user13', '14141414141', 'Mariana Vieira', 'mariana.vieira@biblioteca.com', '11914141414', '1999-10-11', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 13),
('user14', '15151515151', 'Nicolas Ramos', 'nicolas.ramos@biblioteca.com', '11915151515', '2003-05-27', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 14),
('user15', '16161616161', 'Olivia Teixeira', 'olivia.teixeira@biblioteca.com', '11916161616', '2001-03-16', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, 15),

-- Usuários sem turma (turma = NULL)
('user16', '17171717171', 'Paulo Cunha', 'paulo.cunha@biblioteca.com', '11917171717', '1998-12-25', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, NULL),
('user17', '18181818181', 'Renata Pires', 'renata.pires@biblioteca.com', '11918181818', '1997-07-04', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, NULL),
('user18', '19191919191', 'Sandro Lopes', 'sandro.lopes@biblioteca.com', '11919191919', '1996-11-19', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, NULL),
('user19', '20202020202', 'Tatiane Melo', 'tatiane.melo@biblioteca.com', '11920202020', '1995-09-07', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, NULL),
('user20', '21212121212', 'Victor Nogueira', 'victor.nogueira@biblioteca.com', '11921212121', '1994-02-02', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3', 0, NULL),
 
-- Usuários Desenvolvedores
('kevin_machado','59484587097','Kevin Machado','kevinmachado@pallasys.com','98626286837','2004-04-30','9cf06842db77f8de3787395698f1a3d37d45620d265116e72df53f0414d7ab30',16383,NULL); --senha: kevin@123


 
 

