import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/models/livros_resposta.dart';
import 'package:biblioteca/data/services/livro_service.dart';
import 'package:flutter/foundation.dart';

class LivroProvider extends ChangeNotifier {
  final LivroService _livroService = LivroService();
  bool _isLoading = false;
  String? _error;
  List<Livro> _livros = [];
  List<Map<String, dynamic>> _livrosEnvio = [];

  final num idDaSessao;
  final String usuarioLogado;

  LivroProvider(this.idDaSessao, this.usuarioLogado);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasErrors => _error != null;
  List<Livro> get livros => [..._livros];

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Carregar todos os livros
  Future<void> loadLivros() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final livrosAtingidos =
          await _livroService.fetchLivros(idDaSessao, usuarioLogado);
      if (!listEquals(_livros, livrosAtingidos.livrosAtingidos)) {
        _livros = livrosAtingidos.livrosAtingidos;
      }
    } catch (e) {
      _error = "Provider: Erro ao carregar os Livros:\n$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh livros
  Future<void> refreshLivros() async {
    await loadLivros();
  }

  Future<List<Livro>> searchLivros(String textoDeBusca) async {
    LivrosAtingidos? loadedLivros;
    try {
      loadedLivros = await _livroService.searchLivros(
          idDaSessao, usuarioLogado, textoDeBusca);
      return loadedLivros.livrosAtingidos;
    }catch(e){
      throw Exception("LivroProvider: Erro ao pesquisar livro - $e");
    }
  }

  // Adicionar um novo livro
  Future<bool> addLivro(Map<String, dynamic> livro, List<String> autores,
      List<String> categorias) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_livros.any((l) => l.isbn == livro["Isbn"])) {
        _error = "Livro com ISBN ${livro["Isbn"]} já existe.";
        return false;
      }

      await _livroService.addLivro(
          idDaSessao, usuarioLogado, livro, autores, categorias);
      _livrosEnvio.add(livro);
      await loadLivros();
      return true;
    } catch (e) {
      _error = "Erro ao inserir novo Livro:\n$e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Editar um livro existente
  Future<void> editLivro(Map<String, dynamic> livro, List<String> autores,
      List<String> categorias) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _livroService.alterLivro(
          idDaSessao, usuarioLogado, livro, autores, categorias);
      await loadLivros();
    } catch (e) {
      _error = "Erro ao alterar o Livro:\n$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deletar um livro
  Future<void> deleteLivro(int idLivro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_livros.any((livro) => livro.idDoLivro == idLivro)) {
        throw Exception("Livro com ID $idLivro não encontrado.");
      }

      await _livroService.deleteLivro(idDaSessao, usuarioLogado, idLivro);
      _livros.removeWhere((livro) => livro.idDoLivro == idLivro);

      await loadLivros();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
