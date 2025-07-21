import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/models/usuarios_atingidos.dart';
import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/data/services/usuario_service.dart';
import 'package:flutter/material.dart';

class UsuarioProvider with ChangeNotifier {
  final usuarioService = UsuarioService();
  final providerAuth = AuthProvider();
  final num idDaSessao;
  final String usuarioLogado;

  UsuarioProvider(this.idDaSessao, this.usuarioLogado);

  List<Usuario> users = [];

  Future<void> loadUsuarios() async {
    UsuariosAtingidos? loadedUsuarios;
    try {
      loadedUsuarios =
          await usuarioService.fetchUsuarios(idDaSessao, usuarioLogado);
      users = loadedUsuarios.usuarioAtingidos
          .where((usuario) => usuario.ativo && usuario.login != usuarioLogado)
          .toList();

      users.sort((x, y) => x.nome.compareTo(y.nome));

      notifyListeners();
    } catch (e) {
      throw Exception("UsuarioProvider: Erro ao carregar os usuários - $e");
    }
  }
  Future<List<Usuario>> searchUsuarios(String textoDeBusca) async{
    UsuariosAtingidos? loadedUsuarios;
    try{
      loadedUsuarios = await usuarioService.searchUsuarios(idDaSessao, usuarioLogado, textoDeBusca);
      return loadedUsuarios.usuarioAtingidos.where((usuario) => usuario.ativo && usuario.login != usuarioLogado).toList();
    } catch(e){
      throw Exception("UsuarioProvider: Erro ao carregar usuarios pesquisados - $e");
    }
  }

  Future<void> addUsuario(Usuario usuario) async {
    late Usuario novoUsuario;
    try {
      novoUsuario =
          await usuarioService.addUsuario(idDaSessao, usuarioLogado, usuario);
      users.add(novoUsuario);
    } catch (e) {
      throw Exception("UsuarioProvider: Erro ao adicionar o usuário - $e");
    }
    notifyListeners();
  }

  Future<void> editUsuario(Usuario usuario,) async {
    late Usuario novoUsuario;
    try {
      novoUsuario =
          await usuarioService.alterUsuario(idDaSessao, usuarioLogado, usuario);
          if(users.isNotEmpty){
            users[users.indexOf(usuario)] = novoUsuario;
          }

    } catch (e) {
      throw Exception("UsuarioProvider: Erro ao alterar o usuário - $e");
    }
    notifyListeners();
  }

  Future<void> deleteUsuario(int idDoUsuario) async {
    late Usuario usuarioDeletado;
    try {
      usuarioDeletado = await usuarioService.deleteUsuario(
          idDaSessao, usuarioLogado, idDoUsuario);
      users.remove(usuarioDeletado);
    } catch (e) {
      throw Exception("UsuarioProvider: Erro ao deletar o usuário - $e");
    }
    notifyListeners();
  }
}