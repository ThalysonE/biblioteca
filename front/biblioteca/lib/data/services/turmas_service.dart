import 'dart:convert';

import 'package:biblioteca/data/models/api_response_model.dart';
import 'package:biblioteca/data/models/turma.dart';
import 'package:biblioteca/data/services/api_service.dart';

class TurmasService {
  final String apiRoute = 'turmas';
  final ApiService _api = ApiService();

  Future<ApiResponse> fetchTurmas() async {
    List<Turma> turmas = [];

    final Map<String, dynamic> body = {};

    final response = await _api.requisicao(apiRoute, 'GET', body);

    final json = jsonDecode(response.data);

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      turmas = List<Turma>.from(json["Turmas"].map((x) => Turma.fromJson(x)));
    }

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.statusCode == 200 ? turmas : response.data);
  }

  Future<ApiResponse> addTurma(Turma newTurma) async {
    final Map<String, dynamic> body = {
      "Descricao": newTurma.descricao,
      "IdSerie": newTurma.serie,
      "IdTurno": newTurma.turno
    };

    final response = await _api.requisicao(apiRoute, 'POST', body);

    late final Turma turma;

    if (response.statusCode == 200) {
      final json = jsonDecode(response.data)["Turmas"][0];

      turma = Turma.fromJson(json);
    }

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.statusCode == 200 ? turma : response.data);
  }
}
