import 'dart:convert';
import 'package:biblioteca/data/models/livros_resposta.dart';
import 'package:biblioteca/data/services/api_service.dart';

class LivroService {
  final ApiService _api = ApiService();
  final String apiRoute = 'livro';

  // Retorna todos os livros como um objeto LivrosAtingidos
  Future<LivrosAtingidos> fetchLivros(
      num idDaSessao, String loginDoUsuarioBuscador) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioBuscador,
    };

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );

    if (response.statusCode! >= 200 && response.statusCode! < 299) {
      return LivrosAtingidos.fromJson(
          jsonDecode(response.data)); // Retorna a resposta como LivrosAtingidos
    } else {
      throw Exception('Erro ao carregar os livros: ${response.data}');
    }
  }

  Future<LivrosAtingidos> searchLivros(num idDaSessao,
      String loginDoUsuarioRequerente, String textoDeBusca) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "TextoDeBusca": textoDeBusca
    };

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );
    print('Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return livrosAtingidosFromJson(response.data);
  }

  // Criar novo Livro
  Future<void> addLivro(
      num idDaSessao,
      String loginDoUsuarioCriador,
      Map<String, dynamic> livro,
      List<String> autores,
      List<String> categorias) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioCriador,
      "Id": livro["IdDoLivro"],
      "Isbn": livro["Isbn"],
      "Titulo": livro["Titulo"],
      "AnoPublicacao": livro["AnoPublicacao"],
      "Editora": livro["Editora"],
      "Pais": livro["Pais"],
      "NomeDosAutores": autores,
      "NomeDasCategorias": categorias,
    };

    final response = await _api.requisicao(
      apiRoute,
      'POST',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar livro: ${response.data}');
    }
  }

  // Alterar Livro
  Future<void> alterLivro(
      num idDaSessao,
      String loginDoUsuarioRequerente,
      Map<String, dynamic> livro,
      List<String> autores,
      List<String> categorias) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "Id": livro["Id"],
      "Isbn": livro["Isbn"],
      "Titulo": livro["Titulo"],
      "AnoPublicacao": livro["AnoPublicacao"],
      "Editora": livro["Editora"],
      "Pais": livro["Pais"],
      "NomeDosAutores": autores,
      "NomeDasCategorias": categorias,
    };

    final response = await _api.requisicao(
      apiRoute,
      'PUT',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao alterar livro: ${response.data}');
    }
  }

  // Deletar Livro
  Future<void> deleteLivro(
      num idDaSessao, String loginDoUsuarioRequerente, int id) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "Id": id,
    };

    final response = await _api.requisicao(
      apiRoute,
      'DELETE',
      body,
    );

    if (response.statusCode != 204) {
      if (response.statusCode == 400) {
        throw Exception('Dados inválidos: ${response.data}');
      } else if (response.statusCode == 401) {
        throw Exception('Sessão inválida ou expirada');
      } else if (response.statusCode == 403) {
        throw Exception('Sem permissão para excluir o livro');
      } else {
        throw Exception('Erro ao deletar livro: ${response.data}');
      }
    }
  }
}
