import 'dart:convert';

Categoria categoriaFromJson(String str) => Categoria.fromJson(json.decode(str));

String categoriaToJson(Categoria data) => json.encode(data.toJson());

class Categoria {
  int idDaCategoria;
  String descricao;
  bool ativo;

  Categoria({
    required this.idDaCategoria,
    required this.descricao,
    required this.ativo
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idDaCategoria: json["IdDaCategoria"],
        descricao: json["Descricao"],
        ativo: json["Ativo"],
      );

  Map<String, dynamic> toJson() => {
        "IdDaCategoria": idDaCategoria,
        "Descricao": descricao,
        "Ativo": ativo
      };
}
