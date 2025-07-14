import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EmprestimosModel {
  int IdDoEmprestimo;        
	Map<String, dynamic> exemplarMap;              
	Map<String, dynamic> usuarioMap;              
	int numeroRenovacoes = 0;      
	String dataEmprestimo;       
	String dataPrevistaEntrega;
	String dataDeDevolucao;
	int status;
  List<dynamic> detalhes;
  bool checkBox = false; //serve para guardar o estado do exemplar selecionado no checkbox(vai ser o jeitio)
  bool selecionadoRenov = false;
  EmprestimosModel({
    required this.IdDoEmprestimo,
    required this.exemplarMap,
    required this.usuarioMap,
    required this.dataEmprestimo,
    required this.dataPrevistaEntrega,
    required this.dataDeDevolucao,
    required this.status,
    required this.detalhes,
  });
  // Paramentro para formatar a a data: 
  //0 - Data do emprestimo; 1 - Data Prevista Entrega; 2 - Data Devolucao;
  String formatarData(int qualData){
    late String dataFormatada;
    switch(qualData){
      case 0: 
          dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.parse(this.dataEmprestimo));
          break;
      case 1: 
          dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.parse(this.dataPrevistaEntrega));
          break;
      case 2: 
          dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.parse(this.dataDeDevolucao));
          break;
    }
    return dataFormatada;
  }
  factory EmprestimosModel.fromMap(Map<String,dynamic> map){
    return EmprestimosModel(
      IdDoEmprestimo: map['IdDoEmprestimo'], 
      exemplarMap: map['Exemplar'], 
      usuarioMap: map['Usuario'], 
      dataEmprestimo: map['DataEmprestimo'], 
      dataPrevistaEntrega: map['DataDeEntregaPrevista'], 
      dataDeDevolucao: map['DataDeDevolucao'], 
      status: map['Status'], 
      detalhes: map['Detalhes']
    );
  }
}
//modelo para utilizar na msg de confirmacao de emprestimo e renovacao
class emprestimoMsg{
  String tombamento;
  String nome;
  String dataPrevistaEntrega;
  bool renovou = false; // pra saber se a renovaçao desse emprestimo deu certo
  emprestimoMsg(
    { 
      required this.tombamento,
      required this.nome,
      required this.dataPrevistaEntrega,
    }
  );
}
//modelo
// [
//   {
//     "IdDoEmprestimo": 1,
//     "Exemplar": {
//       "IdDoExemplarLivro": 1,
//       "Livro": {
//         "IdDoLivro": 1,
//         "Isbn": "9781234567897",
//         "Titulo": "Dom Casmurro",
//         "AnoPublicacao": "1899-01-01",
//         "Editora": "Editora X",
//         "Pais": 1
//       },
//       "Cativo": false,
//       "Status": 1,
//       "Estado": 1,
//       "Ativo": true
//     },
//     "Usuario": {
//       "IdDoUsuario": 3,
//       "Login": "joao",
//       "Cpf": "26843511040",
//       "Senha": "",
//       "Nome": "João Silva",
//       "Email": "joao.silva@usuario.com",
//       "Telefone": "11987654321",
//       "DataDeNascimento": "1995-08-10",
//       "Permissao": 1,
//       "Ativo": true,
//       "Turma": {
//         "IdTurma": 1,
//         "Descricao": "A",
//         "Serie": {
//           "IdSerie": 1,
//           "Descricao": "1º Ano"
//         },
//         "Turno": {
//           "IdTurno": 1,
//           "Descricao": "Manhã"
//         }
//       }
//     },
//     "DataEmprestimo": "2024-01-01",
//     "NumeroRenovacoes": 0,
//     "DataDeEntregaPrevista": "2024-01-15",
//     "DataDeDevolucao": "",
//     "Status": 1,
//     "Detalhes": [
//       {
//         "IdDetalheEmprestimo": 1,
//         "Usuario": {
//           "IdDoUsuario": 3,
//           "Login": "joao",
//           "Cpf": "26843511040",
//           "Senha": "",
//           "Nome": "João Silva",
//           "Email": "joao.silva@usuario.com",
//           "Telefone": "11987654321",
//           "DataDeNascimento": "1995-08-10",
//           "Permissao": 1,
//           "Ativo": true,
//           "Turma": {
//             "IdTurma": 1,
//             "Descricao": "A",
//             "Serie": {
//               "IdSerie": 1,
//               "Descricao": "1º Ano"
//             },
//             "Turno": {
//               "IdTurno": 1,
//               "Descricao": "Manhã"
//             }
//           }
//         },
//         "DataHora": "2025-05-14",
//         "Acao": 1,
//         "Detalhe": "Empréstimo realizado",
//         "Observacao": ""
//       }
//     ]
//   },
//   {
//     "IdDoEmprestimo": 2,
//     "Exemplar": {
//       "IdDoExemplarLivro": 2,
//       "Livro": {
//         "IdDoLivro": 2,
//         "Isbn": "9780747532743",
//         "Titulo": "Harry Potter e a Pedra Filosofal",
//         "AnoPublicacao": "1997-06-26",
//         "Editora": "Bloomsbury",
//         "Pais": 3
//       },
//       "Cativo": true,
//       "Status": 1,
//       "Estado": 2,
//       "Ativo": true
//     },
//     "Usuario": {
//       "IdDoUsuario": 3,
//       "Login": "joao",
//       "Cpf": "26843511040",
//       "Senha": "",
//       "Nome": "João Silva",
//       "Email": "joao.silva@usuario.com",
//       "Telefone": "11987654321",
//       "DataDeNascimento": "1995-08-10",
//       "Permissao": 1,
//       "Ativo": true,
//       "Turma": {
//         "IdTurma": 1,
//         "Descricao": "A",
//         "Serie": {
//           "IdSerie": 1,
//           "Descricao": "1º Ano"
//         },
//         "Turno": {
//           "IdTurno": 1,
//           "Descricao": "Manhã"
//         }
//       }
//     },
//     "DataEmprestimo": "2024-01-02",
//     "NumeroRenovacoes": 0,
//     "DataDeEntregaPrevista": "2024-01-16",
//     "DataDeDevolucao": "",
//     "Status": 1,
//     "Detalhes": [
//       {
//         "IdDetalheEmprestimo": 2,
//         "Usuario": {
//           "IdDoUsuario": 3,
//           "Login": "joao",
//           "Cpf": "26843511040",
//           "Senha": "",
//           "Nome": "João Silva",
//           "Email": "joao.silva@usuario.com",
//           "Telefone": "11987654321",
//           "DataDeNascimento": "1995-08-10",
//           "Permissao": 1,
//           "Ativo": true,
//           "Turma": {
//             "IdTurma": 1,
//             "Descricao": "A",
//             "Serie": {
//               "IdSerie": 1,
//               "Descricao": "1º Ano"
//             },
//             "Turno": {
//               "IdTurno": 1,
//               "Descricao": "Manhã"
//             }
//           }
//         },
//         "DataHora": "2025-05-14",
//         "Acao": 2,
//         "Detalhe": "Renovação solicitada",
//         "Observacao": ""
//       }
//     ]
//   }
// ]
