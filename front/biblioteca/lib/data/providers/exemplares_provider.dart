// Provider para gerenciar o estado de Exemplares
import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/data/models/exemplar_model.dart';

import 'package:biblioteca/data/services/exemplares_service.dart';

class ExemplarProvider with ChangeNotifier {
  final ExemplarService exemplarService = ExemplarService();
  List<Exemplar> exemplares = [];
  List<ExemplarEnvio> exemplaresEnvio = [];
  final num idDaSessao;
  final String usuarioLogado;
  List<EmprestimosModel> listaEmprestados = []; //alterei so isso aqui
  ExemplarProvider(this.idDaSessao, this.usuarioLogado);

  void addExemplarEmprestado(List<EmprestimosModel> exemplares) {
    listaEmprestados.addAll(exemplares);
    print(listaEmprestados);
    notifyListeners();
  }

  // Carrega a lista de exemplares
  Future<void> loadExemplares() async {
    try {
      final response =
          await exemplarService.fetchExemplares(idDaSessao, usuarioLogado);
      exemplares = response.exemplares;
      exemplares.sort((a, b) => a.titulo.compareTo(b.titulo));
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao carregar os exemplares: $e");
    }
  }


  // Adiciona um novo exemplar
  Future<void> addExemplar(ExemplarEnvio exemplar) async {
    try {
      final novoExemplar = await exemplarService.addExemplar(
          idDaSessao, usuarioLogado, exemplar);
      exemplaresEnvio.add(novoExemplar);
      exemplaresEnvio.sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao adicionar o exemplar: $e");
    }
  }

  // Altera um exemplar existente
  Future<void> alterExemplar(Exemplar exemplar) async {
    try {
      final exemplarAtualizado = await exemplarService.alterExemplar(
          idDaSessao, usuarioLogado, exemplar);
      final index = exemplares.indexWhere((e) => e.id == exemplar.id);

      
      if (index != -1) {
        exemplares[index] = exemplarAtualizado;
        exemplares.sort((a, b) => a.titulo.compareTo(b.titulo));
        notifyListeners();
      }
      
    } catch (e) {
      throw Exception("Erro ao alterar o exemplar: $e");
    }
  }

  // Remove (inativa) um exemplar
  Future<void> deleteExemplar(int id) async {
    try {
      final exemplarRemovido =
          await exemplarService.deleteExemplar(idDaSessao, usuarioLogado, id);
      exemplares.removeWhere((exemplar) => exemplar.id == exemplarRemovido.id);
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao remover o exemplar: $e");
    }
  }
  Future<List<Exemplar>> fetchExemplaresIdLivro(int idLivro) async {
    List<Exemplar> exemplareIdLivro = [];
    final response = await exemplarService.searchExemplaresIdLivro(idDaSessao, usuarioLogado, idLivro);
    exemplareIdLivro = response.exemplares;
    return exemplareIdLivro;
  }
}
