import 'dart:convert';
import 'package:biblioteca/data/models/dashboard_model.dart';
import 'package:biblioteca/data/services/api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  final String apiRoute = 'dashboard';

  Future<DashboardModel?> fetchDashboard(
      num idDaSessao, String loginDoUsuarioRequerente) async {
    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
    };
    final response = await _apiService.requisicao(
      apiRoute,
      'GET',
      body,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }

    if (response.data is Map) {
      return DashboardModel.fromJson(response.data);
    } else if (response.data is String) {
      return DashboardModel.fromJson(
          response.data.isNotEmpty ? jsonDecode(response.data) : {});
    }
    return null;
  }
}
