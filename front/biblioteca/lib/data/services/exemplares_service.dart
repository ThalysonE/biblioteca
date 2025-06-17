import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/exemplares_resposta.dart';
import 'package:biblioteca/data/services/api_service.dart';

class ExemplarService {
  final ApiService _api = ApiService();
  final String apiRoute = 'exemplar';

  // Retorna todos os exemplares
  Future<ExemplaresAtingidos> fetchExemplares(
      num idDaSessao, String loginDoUsuarioRequerente) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
    };

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return exemplaresAtingidosFromJson(response.data);
  }

  //Pesquisa os exemplare
  Future<ExemplaresAtingidos> searchExemplares(num idDaSessao,
      String loginDoUsuarioRequerente, String textoDeBusca) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      
    };
    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );
    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return exemplaresAtingidosFromJson(response.data);
  }

  // Cria um novo exemplar
  Future<ExemplarEnvio> addExemplar(num idDaSessao,
      String loginDoUsuarioRequerente, ExemplarEnvio exemplar) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "IdDoExemplarLivro": exemplar.id,
      "IdDoLivro": exemplar.idLivro,
      "Estado": exemplar.estado,
      "Status": 1, // 0 - emprestado 1 - disponivel 2 - indisponivel NOTA: colocar isso num enum
      "Ativo": exemplar.ativo
    };

    final response = await _api.requisicao(
      apiRoute,
      'POST',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }

    return exemplaresEnvioAtingidosFromJson(response.data).exemplaresEnvio[0];
  }

  // Altera um exemplar existente
  Future<Exemplar> alterExemplar(num idDaSessao,
      String loginDoUsuarioRequerente, Exemplar exemplar) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "IdDoExemplarLivro": exemplar.id,
      "Titulo": exemplar.titulo,
      "AnoPublicacao": exemplar.anoPublicacao.toIso8601String(),
      "Editora": exemplar.editora,
      "Isbn": exemplar.isbn,
      "IdDoLivro": exemplar.idLivro,
      "Estado": exemplar.estado,
      "Status": exemplar.statusCodigo,
      "Ativo": exemplar.ativo
    };

    final response = await _api.requisicao(
      apiRoute,
      'PUT',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }

    return exemplaresAtingidosFromJson(response.data).exemplares[0];
  }

  // Remove (inativa) um exemplar
  Future<Exemplar> deleteExemplar(
      num idDaSessao, String loginDoUsuarioRequerente, int id) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "IdDoExemplarLivro": id
    };
    final response = await _api.requisicao(
      apiRoute,
      'DELETE',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }

    return exemplaresAtingidosFromJson(response.data).exemplares[0];
  }
  Future<ExemplaresAtingidos> searchExemplaresIdLivro(num idDaSessao,
      String loginDoUsuarioRequerente, int idDolivro) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "IdDoLivro": idDolivro
    };
    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );
    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return exemplaresAtingidosFromJson(response.data);
  }
}
