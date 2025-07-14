import 'package:biblioteca/data/models/turma.dart';
import 'package:biblioteca/data/services/turmas_service.dart';
import 'package:flutter/material.dart';

class TurmasProvider extends ChangeNotifier {
  final TurmasService _turmasService = TurmasService();
  bool _isLoading = false;
  String? _error;
  List<Turma> _turmas = [];

  //Uns getters
  bool get isloading => _isLoading;
  String? get error => _error;
  bool get hasErrors => _error != null ? true : false;
  List<Turma> get turma => _turmas;

  Future<void> loadTurmas() async {
    _isLoading = true;
    _error = null;
    // notifyListeners();

    try {
      final apiResponse = await _turmasService.fetchTurmas();

      if (apiResponse.responseCode == 200) {
        _turmas = apiResponse.body;
      } else {
        _error = apiResponse.body;
      }
    } catch (e) {
      _error = "Erro ao carregar as Turmas:\n$e";
    } finally {
      _isLoading = false;
      // notifyListeners();
    }
  }

  Future<void> addTurma(Turma turma) async {
    _isLoading = true;
    _error = null;
    // notifyListeners();

    try {
      final apiResponse = await _turmasService.addTurma(turma);

      if (apiResponse.responseCode > 299) {
        _error = apiResponse.body;
      } else {
        _turmas.add(apiResponse.body);
      }
    } catch (e) {
      _error = "Erro ao inserir nova Turma:\n$e";
    } finally {
      _isLoading = false;
      // notifyListeners();
    }
  }
}
