// Provider para gerenciar o estado de empresimo
import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/services/emprestimo_service.dart';
import 'package:flutter/material.dart';


class EmprestimoProvider with ChangeNotifier {
  final EmprestimoService emprestimoService = EmprestimoService();
  final num idDaSessao;
  final String usuarioLogado;
  EmprestimoProvider(this.idDaSessao, this.usuarioLogado);

  //Para buscar todos os emprestimos para o DashBoard
  Future<List<EmprestimosModel>> fetchTodosEmprestimos() async {
     final emprestimos = await emprestimoService.fetchTodosEmprestimos(idDaSessao, usuarioLogado);
     return emprestimos;
  }
  
  Future<List<EmprestimosModel>> fetchEmprestimosUsuario(int idAluno) async {
    try {
     final emprestimos = await emprestimoService.fetchEmprestimosUsuario(idDaSessao, usuarioLogado, idAluno);
     return emprestimos;
    } catch (e) {
      print("Erro ao buscar emprestimos: $e");
      return [];
    } 
  }
  
  Future<List<EmprestimosModel>> fetchEmprestimoEmAndamentoUsuarios(int idAluno) async {
    try {
     final emprestimos = await emprestimoService.fetchEmprestimosUsuario(idDaSessao, usuarioLogado, idAluno);

      // O filtro fica no provider agora
     return emprestimos.where((e) => e.status == 1).toList();
    } catch (e) {
      print("Erro ao buscar emprestimos: $e");
      return [];
    } 
  }

  Future<int?> addEmprestimo(int idAluno, List<int> exemplaresEmprestados) async {
    try {
     final statusCode = await emprestimoService.addEmprestimo(idDaSessao, usuarioLogado, idAluno, exemplaresEmprestados);
     return statusCode;
    } catch (e) {
      print("Erro ao criar empréstimo: $e");
      return null;
    }
  }
  Future<int?> renovacao(int idEmprestimo) async {
    try {
     final statusCode = await emprestimoService.renovarEmprestimo(idDaSessao, usuarioLogado, idEmprestimo);
     print('Status renovacao : ${statusCode}');
     return statusCode;
    } catch (e) {
      print("Erro ao renovar Emprestimo: $e");
      return null;
    }
  }
  Future<List<EmprestimosModel>> fetchEmprestimoExemplar(int idExemplar) async{
    try{
      final emprestimo = await emprestimoService.fetchEmprestimoExemplar(idDaSessao, usuarioLogado, idExemplar);
      return emprestimo;
    }catch(e){
      print('Erro ao pesquisar emprestimo: ${e}');
      return [];
    }
  }
  Future<int?> devolver(int idEmprestimo) async {
    try {
     final statusCode = await emprestimoService.devolverEmprestimo(idDaSessao, usuarioLogado, idEmprestimo);
     print('Status Devolucao : ${statusCode}');
     return statusCode;
    } catch (e) {
      print("Erro ao renovar Devolver Exemplar: $e");
      return null;
    }
  }
}
