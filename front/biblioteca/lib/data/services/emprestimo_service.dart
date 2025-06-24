import 'dart:convert';

import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/exemplares_resposta.dart';
import 'package:biblioteca/data/services/api_service.dart';

class EmprestimoService {
  final ApiService _api = ApiService();
  final String apiRoute = 'emprestimo';

  //Para buscar todos os emprestimos para o DashBoard
  Future<List<EmprestimosModel>> fetchTodosEmprestimos(
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
    List<EmprestimosModel> emprestimos = [];
    final respostaFinal = jsonDecode(response.data);
    respostaFinal.map((item) {
      final emprestimo = EmprestimosModel.fromMap(item);
      emprestimos.add(emprestimo);
    }).toList();
    
    return emprestimos;
  }

  // Retorna todos os exemplares
  Future<List<EmprestimosModel>> fetchEmprestimosUsuario(
      num idDaSessao, String loginDoUsuarioRequerente, int idUsuario) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "idDoUsuarioAluno": idUsuario
    };

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    List<EmprestimosModel> emprestimos = [];
    final respostaFinal = jsonDecode(response.data);


    emprestimos = List<EmprestimosModel>.from(respostaFinal.map((x) => EmprestimosModel.fromMap(x)));

    // O filtro agora fica no provider
    // respostaFinal.map((item) {
    //   if (item['Status'] == 1) {
    //     final emprestimo = EmprestimosModel.fromMap(item);
    //     emprestimos.add(emprestimo);
    //   }
    // }).toList();

    return emprestimos;
  }

  Future<List<EmprestimosModel>> fetchEmprestimoExemplar(
      num idDaSessao, String loginDoUsuarioRequerente, int idExemplar) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "idDoExemplar": idExemplar
    };

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    List<EmprestimosModel> emprestimos = [];
    final respostaFinal = jsonDecode(response.data);
    respostaFinal.map((item) {
      if (item['Status'] == 1) {
        final emprestimo = EmprestimosModel.fromMap(item);
        emprestimos.add(emprestimo);
      }
    }).toList();
    return emprestimos;
  }

  // Cria um novo emprestimo
  Future<int?> addEmprestimo(num idDaSessao, String loginDoUsuarioRequerente,
      int idAluno, List<int> exemplares) async {
    final Map<String, dynamic> body = {
      "idDaSessao": idDaSessao,
      "loginDoUsuario": loginDoUsuarioRequerente,
      "idDoAluno": idAluno,
      "idsExemplares": exemplares
    };
    final response = await _api.requisicao(
      apiRoute,
      'POST',
      body,
    );
    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return response.statusCode;
  }

  // Altera um exemplar existente
  Future<Exemplar> alterExemplar(num idDaSessao,
      String loginDoUsuarioRequerente, Exemplar exemplar) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuario": loginDoUsuarioRequerente,
      "IdDoExemplarLivro": exemplar.id,
      "Titulo": exemplar.titulo,
      "AnoPublicacao": exemplar.anoPublicacao,
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

  Future<int?> renovarEmprestimo(
      num idDaSessao, String loginDoUsuarioRequerente, int idEmprestimo) async {
    final Map<String, dynamic> body = {
      "idDaSessao": idDaSessao,
      "loginDoUsuario": loginDoUsuarioRequerente,
      "idDoEmprestimo": idEmprestimo,
    };
    final response = await _api.requisicao(
      apiRoute,
      'PUT',
      body,
    );
    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return response.statusCode;
  }

  Future<int?> devolverEmprestimo(
      num idDaSessao, String loginDoUsuarioRequerente, int idEmprestimo) async {
    final Map<String, dynamic> body = {
      "idDaSessao": idDaSessao,
      "loginDoUsuario": loginDoUsuarioRequerente,
      "idDoEmprestimo": idEmprestimo,
    };
    final response = await _api.requisicao(
      apiRoute,
      'DELETE',
      body,
    );
    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
    return response.statusCode;
  }
}
