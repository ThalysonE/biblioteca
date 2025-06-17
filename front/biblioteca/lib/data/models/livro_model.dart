// To parse this JSON data, do
//
//     final livro = livroFromJson(jsonString);

import 'dart:convert';

import 'package:biblioteca/data/models/exemplar_model.dart';

Livro livroFromJson(String str) => Livro.fromJson(json.decode(str));
String livroToJson(Livro data) => json.encode(data.toJson());

LivroEnvio livroEnvioFromJson(String str) =>
    LivroEnvio.fromJson(json.decode(str));
String livroEnvioToJson(LivroEnvio data) => json.encode(data.toJson());

class LivroEnvio {
  int idDoLivro;
  String isbn;
  String titulo;
  String anoPublicacao;
  String editora;
  int pais;

  LivroEnvio(
      {required this.idDoLivro,
      required this.isbn,
      required this.titulo,
      required this.anoPublicacao,
      required this.editora,
      required this.pais});

  factory LivroEnvio.fromJson(Map<String, dynamic> json) => LivroEnvio(
        idDoLivro: json["IdDoLivro"],
        isbn: json["Isbn"],
        titulo: json["Titulo"],
        anoPublicacao: json["AnoPublicacao"],
        editora: json["Editora"],
        pais: json["Pais"],
      );

  Map<String, dynamic> toJson() => {
        "IdDoLivro": idDoLivro,
        "Isbn": isbn,
        "Titulo": titulo,
        "AnoPublicacao": anoPublicacao,
        "Editora": editora,
        "Pais": pais,
      };
}

class Livro {
  int idDoLivro;
  String isbn;
  String titulo;
  DateTime anoPublicacao;
  String editora;
  Map<String, dynamic> pais;
  List<dynamic> categorias;
  List<dynamic> autores;
  List<Exemplar> listaExemplares = []; // serve pra  guardar os exemplares do livro (usado na pesquisa de livros)

  Livro({
    required this.idDoLivro,
    required this.isbn,
    required this.titulo,
    required this.anoPublicacao,
    required this.editora,
    required this.pais,
    required this.categorias,
    required this.autores,
  });

  factory Livro.fromJson(Map<String, dynamic> json) => Livro(
      idDoLivro: json["IdDoLivro"],
      isbn: json["Isbn"],
      titulo: json["Titulo"],
      anoPublicacao: DateTime.parse(json["AnoPublicacao"]),
      editora: json["Editora"],
      pais: json["Pais"],
      categorias: json['Categorias'] ?? [],
      autores: json['Autores'] ?? []);

  Map<String, dynamic> toJson() => {
        "IdDoLivro": idDoLivro,
        "Isbn": isbn,
        "Titulo": titulo,
        "AnoPublicacao":
            "${anoPublicacao.year.toString().padLeft(4, '0')}-${anoPublicacao.month.toString().padLeft(2, '0')}-${anoPublicacao.day.toString().padLeft(2, '0')}",
        "Editora": editora,
        "Pais": pais,
        "Categorias": categorias,
        "Autores": autores,
      };
}
