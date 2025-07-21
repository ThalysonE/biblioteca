import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/services/usuario_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final uusuarioService = UsuarioService();
  num _idDaSessao = 0;
  String usuarioLogado = '';
  late Usuario uusuario;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  num get idDaSessao => _idDaSessao;
  Usuario get usuario => uusuario;
  void atualizarUsuario(Usuario novoUsuario) {
    uusuario = novoUsuario;
    notifyListeners();
  }
  Future login(num idDaSessao, String loginDoUsuario) async {
    print(idDaSessao);
    _idDaSessao = idDaSessao;
    usuarioLogado = loginDoUsuario;

    try {
      final usuariosAtingidos = await uusuarioService.searchUsuarios(
          idDaSessao, usuarioLogado, "");

      uusuario = usuariosAtingidos.usuarioAtingidos[0];
    } catch (e) {
      print("Erro ao carregar o usuario logado: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _idDaSessao = 0;
    usuarioLogado = '';
    notifyListeners();
  }
}
