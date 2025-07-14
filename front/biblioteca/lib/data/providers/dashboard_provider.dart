import 'package:biblioteca/data/models/dashboard_model.dart';
import 'package:biblioteca/data/services/dashboard_service.dart';
import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService dashboardService = DashboardService();

  DashboardModel? dashboard;
  bool isLoading = false;
  String? error;

  Future<void> fetchDashboard(
      num idDaSessao, String loginDoUsuarioRequerente) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      dashboard = await dashboardService.fetchDashboard(
          idDaSessao, loginDoUsuarioRequerente);
    } catch (e) {
      error = 'Erro ao buscar dashboard: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
