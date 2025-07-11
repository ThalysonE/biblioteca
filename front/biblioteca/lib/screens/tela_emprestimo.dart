import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/emprestimo_provider.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/widgets/tables/history_table.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PaginaEmprestimo extends StatefulWidget {
  const PaginaEmprestimo({super.key});

  @override
  State<PaginaEmprestimo> createState() => _PaginaEmprestimoState();
}

class _PaginaEmprestimoState extends State<PaginaEmprestimo> {
  late TextEditingController _searchController;
  late TextEditingController _searchControllerBooks;
  late List<Usuario> _filteredUsers;
  bool search = false;
  bool showSearchBooks = false;
  bool showBooks = false;
  bool showLivrosEmprestados = false;
  int selectOption = -1;
  Exemplar? selectbook;
  Usuario? selectUser;
  late ExemplarProvider providerExemplar;
  late List<Exemplar> exemplares;

  late List<Exemplar> selectedBoxExemplar = [];

  late List<EmprestimosModel> emprestimos = [];

  int rowsPerPageUsers = 10;
  final List<int> rowsPerPageOptionsUsers = [5, 10, 15, 20];
  int currentPageUsers = 1;
  String _tableFilterTextUsers = '';
  final TextEditingController _tableFilterControllerUsers =
      TextEditingController();
  String _sortColumnUsers = 'nome'; // 'nome', 'turma', 'turno', 'email', 'tipo'
  bool _isAscendingUsers = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchControllerBooks = TextEditingController();
    providerExemplar = Provider.of<ExemplarProvider>(context, listen: false);
    _filteredUsers = [];

    if (providerExemplar.exemplares.isEmpty) {
      Provider.of<ExemplarProvider>(context, listen: false)
          .loadExemplares()
          .then((_) {
        setState(() {});
      });
    }
  }

  scafoldMsg(String msg, int tipo) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: tipo == 1
          ? Colors.red
          : (tipo == 2)
              ? Colors.orange
              : Colors.green,
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  void searchUsers() async {
    final searchQuery = _searchController.text.toLowerCase();
    if (showSearchBooks) {
      selectUser = null;
      showBooks = false;
      showSearchBooks = false;
      selectbook = null;
      _searchControllerBooks.text = '';
      setState(() {});
    }
    if (searchQuery.isNotEmpty) {
      try {
        final resposta =
            await Provider.of<UsuarioProvider>(context, listen: false)
                .searchUsuarios(searchQuery);
        setState(() {
          search = true;
          _filteredUsers = resposta;
        });
      } catch (e) {
        print(e.toString());
        scafoldMsg(
            'Erro ao realizar a pesquisa de usuários. Tente novamente mais tarde.',
            1);
      }
    }
  }

  void searchBooks() {
    showBooks = true;
    final searchQuery = _searchControllerBooks.text.trim();

    setState(() {
      if (searchQuery.isEmpty) {
        selectbook = null;
        return;
      }

      final searchId = int.tryParse(searchQuery);
      if (searchId != null) {
        try {
          selectbook = exemplares.firstWhere(
            (exemplar) => exemplar.id == searchId,
          );
        } catch (e) {
          selectbook = null;
          scafoldMsg('Exemplar não encontrado!', 1);
        }

        if (selectbook != null) {
          if (emprestimos.any(
              (e) => e.exemplarMap['IdDoExemplarLivro'] == selectbook!.id)) {
            scafoldMsg('Exemplar já emprestado para o aluno!', 1);
          } else if (!selectedBoxExemplar.contains(selectbook)) {
            if (selectbook!.statusCodigo != 1) {
              //mudar isso aqui dps para (selectbook!.statusCodigo != 1) pq a api da com bug de definir o status de todos os exemplares como 0
              msgIndisponivel(selectbook!);
            } else {
              setState(() {
                selectedBoxExemplar.add(selectbook!);
              });
            }
          } else {
            scafoldMsg('Exemplar já adicionado!', 2);
          }
        }
      }
    });
  }

  Future<void> msgIndisponivel(Exemplar exemplar) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                'Exemplar indisponível para empréstimo',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Container(
                width: 800,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.08),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(0.10),
                    3: FlexColumnWidth(0.11)
                  },
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  children: [
                    const TableRow(
                        decoration:
                            BoxDecoration(color: Color.fromRGBO(38, 42, 79, 1)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Tombamento",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Título",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Ano de Publicação",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Situação",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          )
                        ]),
                    TableRow(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(233, 235, 238, 75)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(exemplar.id.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(exemplar.titulo,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${exemplar.anoPublicacao}',
                                // DateFormat('dd/MM/YYYY')
                                //     .format(exemplar.anoPublicacao),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(exemplar.getStatus,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        ])
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(11),
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 15.5),
                        )),
                    if (exemplar.statusCodigo == 1)
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          TextButton(
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(11),
                                  backgroundColor: Colors.green[400],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              onPressed: () {
                                setState(() {
                                  selectedBoxExemplar.add(exemplar);
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Selecionar',
                                  style: TextStyle(fontSize: 15.5)))
                        ],
                      )
                  ],
                )
              ],
            ));
  }

  Future<void> msgConfirmEmprestimo(
      List<emprestimoMsg> exemplaresEmpres, int tipoMsg) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                tipoMsg == 0
                    ? 'Confirmação de Empréstimo'
                    : 'Confimação de Renovação',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Container(
                width: 800,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.08),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(0.10),
                    3: FlexColumnWidth(0.11)
                  },
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  children: [
                    const TableRow(
                        decoration:
                            BoxDecoration(color: Color.fromRGBO(38, 42, 79, 1)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Tombamento",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Título",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Data Devolução",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Situação",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          )
                        ]),
                    for (emprestimoMsg exemplar in exemplaresEmpres)
                      TableRow(
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(233, 235, 238, 75)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(exemplar.tombamento,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(exemplar.nome,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(exemplar.dataPrevistaEntrega,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  tipoMsg == 0
                                      ? 'Empréstimo realizado!'
                                      : (exemplar.renovou)
                                          ? 'Renovação realizada!'
                                          : 'Limite Máximo de Renovação Atingido',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: tipoMsg == 0
                                          ? Colors.green[400]
                                          : exemplar.renovou
                                              ? Colors.green[400]
                                              : Colors.red[400])),
                            )
                          ])
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(11),
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(fontSize: 15.5),
                        )),
                  ],
                )
              ],
            ));
  }

  String dataPrevistaDevolucao(DateTime dateNow) {
    DateTime dataDevolucaoDate = dateNow.add(const Duration(days: 7));
    final dataDevolucao = DateFormat('dd/MM/yyyy').format(dataDevolucaoDate);
    return dataDevolucao;
  }

  Future<void> renovarExemplares(
      List<EmprestimosModel> emprestimosRenov) async {
    final copia = List.from(emprestimosRenov);
    List<emprestimoMsg> listaRenovacao = [];
    for (EmprestimosModel emprestimo in emprestimosRenov) {
      listaRenovacao.add(emprestimoMsg(
          tombamento: emprestimo.exemplarMap['IdDoExemplarLivro'].toString(),
          nome: emprestimo.exemplarMap['Livro']['Titulo'],
          dataPrevistaEntrega: emprestimo.formatarData(1)));
    }
    for (final item in copia) {
      var status = await Provider.of<EmprestimoProvider>(context, listen: false)
          .renovacao(item.IdDoEmprestimo);
      final exemplarRenov = listaRenovacao.firstWhere((exemplar) =>
          exemplar.tombamento ==
          item.exemplarMap['IdDoExemplarLivro'].toString());
      if (status == 200) {
        exemplarRenov.renovou = true;
        exemplarRenov.dataPrevistaEntrega = dataPrevistaDevolucao(
            DateFormat('dd/MM/yyyy').parse(exemplarRenov.dataPrevistaEntrega));
      } else {
        exemplarRenov.renovou = false;
      }
    }

    msgConfirmEmprestimo(listaRenovacao, 1);
    carregarEmprestimosUsuario(selectUser!.idDoUsuario);
  }

  void carregarEmprestimosUsuario(int idUsuario) async {
    emprestimos = await Provider.of<EmprestimoProvider>(context, listen: false)
        .fetchEmprestimoEmAndamentoUsuarios(idUsuario);
    setState(() {});
  }

  void realizarEmprestimo(List<Exemplar> exemplaresParaEmprestar) async {
    List<int> listaIdsExemplares = [];
    for (Exemplar item in exemplaresParaEmprestar) {
      listaIdsExemplares.add(item.id);
    }
    final statusCode =
        await Provider.of<EmprestimoProvider>(context, listen: false)
            .addEmprestimo(selectUser!.idDoUsuario, listaIdsExemplares);

    if (statusCode == 200) {
      List<emprestimoMsg> listaEmprestados = [];
      for (Exemplar item in exemplaresParaEmprestar) {
        listaEmprestados.add(emprestimoMsg(
            tombamento: item.id.toString(),
            nome: item.titulo,
            dataPrevistaEntrega: dataPrevistaDevolucao(DateTime.now())));
      }
      msgConfirmEmprestimo(listaEmprestados, 0);
      carregarEmprestimosUsuario(selectUser!.idDoUsuario);
    } else {
      scafoldMsg(
          'Erro ao tentar realizar o emprestimo, tente novamente mais tarde!',
          1);
    }
  }

  void _abrirHistoricoUsuario(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryTablePage(
          usuario: usuario,
          ultimaPagina: "Empréstimo",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchControllerBooks.dispose();
    _tableFilterControllerUsers.dispose();
    super.dispose();
  }

  List<Usuario> _getPaginatedUsers() {
    // Filtra os usuários com base no texto da tabela
    List<Usuario> filtered = _filteredUsers.where((user) {
      final nome = user.nome.toLowerCase();
      final turma = user.getTurma.toLowerCase();
      final turno = user.getTurno.toLowerCase();
      final email = user.email.toLowerCase();
      final tipo = user.getTipoDeUsuario.toLowerCase();
      final filter = _tableFilterTextUsers.toLowerCase();

      return nome.contains(filter) ||
          turma.contains(filter) ||
          turno.contains(filter) ||
          email.contains(filter) ||
          tipo.contains(filter);
    }).toList();

    // Ordena os usuários com base na coluna e ordem selecionadas
    filtered.sort((a, b) {
      int res = 0;
      if (_sortColumnUsers == 'nome') {
        res = a.nome.compareTo(b.nome);
      } else if (_sortColumnUsers == 'turma') {
        res = a.getTurma.compareTo(b.getTurma);
      } else if (_sortColumnUsers == 'turno') {
        res = a.getTurno.compareTo(b.getTurno);
      } else if (_sortColumnUsers == 'email') {
        res = a.email.compareTo(b.email);
      } else if (_sortColumnUsers == 'tipo') {
        res = a.getTipoDeUsuario.compareTo(b.getTipoDeUsuario);
      }

      return _isAscendingUsers ? res : -res;
    });

    // Pagina os resultados
    int start = (currentPageUsers - 1) * rowsPerPageUsers;
    int end = start + rowsPerPageUsers;
    return filtered.sublist(
        start, end > filtered.length ? filtered.length : end);
  }

  int _getTotalPagesUsers() {
    // Retorna o número total de páginas com base na quantidade de usuários filtrados
    int totalFiltered = _filteredUsers
        .where((user) {
          final nome = user.nome.toLowerCase();
          final turma = user.getTurma.toLowerCase();
          final turno = user.getTurno.toLowerCase();
          final email = user.email.toLowerCase();
          final tipo = user.getTipoDeUsuario.toLowerCase();
          final filter = _tableFilterTextUsers.toLowerCase();

          return nome.contains(filter) ||
              turma.contains(filter) ||
              turno.contains(filter) ||
              email.contains(filter) ||
              tipo.contains(filter);
        })
        .toList()
        .length;

    return (totalFiltered / rowsPerPageUsers).ceil();
  }

  @override
  Widget build(BuildContext context) {
    exemplares = providerExemplar.exemplares;
    return Material(
      child: Column(
        children: [
          const BreadCrumb(
              breadcrumb: ['Início', 'Empréstimo'],
              icon: Icons.my_library_books_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisa De Aluno",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 26)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 800, maxHeight: 40, minWidth: 200),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Insira o nome do aluno",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onSubmitted: (value) {
                            searchUsers();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                            left: 16,
                            right: 20,
                          ),
                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: searchUsers,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text("Pesquisar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (_filteredUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum usuário encontrado',
                          style: TextStyle(fontSize: 16)),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectUser == null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 1210, minWidth: 800),
                            child: Column(
                              children: [
                                // Filtro e seleção de registros por página
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16.0, top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Registros por página
                                      Row(
                                        children: [
                                          const Text('Exibir'),
                                          const SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: rowsPerPageUsers,
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  rowsPerPageUsers = value;
                                                  currentPageUsers = 1;
                                                });
                                              }
                                            },
                                            items: rowsPerPageOptionsUsers
                                                .map((int value) {
                                              return DropdownMenuItem<int>(
                                                  value: value,
                                                  child:
                                                      Text(value.toString()));
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('registros por página'),
                                        ],
                                      ),
                                      // Campo de filtro
                                      SizedBox(
                                        width: 300,
                                        child: TextField(
                                          controller:
                                              _tableFilterControllerUsers,
                                          decoration: const InputDecoration(
                                            labelText: 'Pesquisar',
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _tableFilterTextUsers =
                                                  value.toLowerCase();
                                              currentPageUsers = 1;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tabela com ordenação
                                Table(
                                  border: TableBorder.all(
                                      color: const Color.fromARGB(
                                          215, 200, 200, 200)),
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.42),
                                    1: FlexColumnWidth(0.18),
                                    2: FlexColumnWidth(0.18),
                                    3: FlexColumnWidth(0.36),
                                    4: FlexColumnWidth(0.17),
                                    5: FlexColumnWidth(0.20),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color.fromRGBO(38, 42, 79, 1)),
                                      children: [
                                        // Nome - Ordenável
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (_sortColumnUsers ==
                                                    'nome') {
                                                  _isAscendingUsers =
                                                      !_isAscendingUsers;
                                                } else {
                                                  _sortColumnUsers = 'nome';
                                                  _isAscendingUsers = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                const Text('Nome',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                Icon(
                                                  _sortColumnUsers == 'nome'
                                                      ? (_isAscendingUsers
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward)
                                                      : Icons.unfold_more,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Turma - Ordenável
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (_sortColumnUsers ==
                                                    'turma') {
                                                  _isAscendingUsers =
                                                      !_isAscendingUsers;
                                                } else {
                                                  _sortColumnUsers = 'turma';
                                                  _isAscendingUsers = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text('Turma',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                Icon(
                                                  _sortColumnUsers == 'turma'
                                                      ? (_isAscendingUsers
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward)
                                                      : Icons.unfold_more,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Turno - Ordenável
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (_sortColumnUsers ==
                                                    'turno') {
                                                  _isAscendingUsers =
                                                      !_isAscendingUsers;
                                                } else {
                                                  _sortColumnUsers = 'turno';
                                                  _isAscendingUsers = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text('Turno',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                Icon(
                                                  _sortColumnUsers == 'turno'
                                                      ? (_isAscendingUsers
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward)
                                                      : Icons.unfold_more,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Email - Ordenável
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (_sortColumnUsers ==
                                                    'email') {
                                                  _isAscendingUsers =
                                                      !_isAscendingUsers;
                                                } else {
                                                  _sortColumnUsers = 'email';
                                                  _isAscendingUsers = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                const Text('Email',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                Icon(
                                                  _sortColumnUsers == 'email'
                                                      ? (_isAscendingUsers
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward)
                                                      : Icons.unfold_more,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Tipo Usuário - Ordenável
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (_sortColumnUsers ==
                                                    'tipo') {
                                                  _isAscendingUsers =
                                                      !_isAscendingUsers;
                                                } else {
                                                  _sortColumnUsers = 'tipo';
                                                  _isAscendingUsers = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text('Tipo Usuário',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                Icon(
                                                  _sortColumnUsers == 'tipo'
                                                      ? (_isAscendingUsers
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward)
                                                      : Icons.unfold_more,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Ação (não ordenável)
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Ação',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                    // Linhas de dados paginadas
                                    for (int x = 0;
                                        x < _getPaginatedUsers().length;
                                        x++)
                                      TableRow(
                                        decoration: BoxDecoration(
                                            color: x % 2 == 0
                                                ? const Color.fromRGBO(
                                                    233, 235, 238, 75)
                                                : const Color.fromRGBO(
                                                    255, 255, 255, 1)),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 8),
                                            child: Text(
                                                _getPaginatedUsers()[x].nome,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 8),
                                            child: Text(
                                                _getPaginatedUsers()[x]
                                                    .getTurma,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 8),
                                            child: Text(
                                                _getPaginatedUsers()[x]
                                                    .getTurno,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 8),
                                            child: Text(
                                                _getPaginatedUsers()[x].email,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13, horizontal: 8),
                                            child: Text(
                                                _getPaginatedUsers()[x]
                                                    .getTipoDeUsuario,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 14,
                                            ),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 45, 106, 79),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                              ),
                                              onPressed: () {
                                                showSearchBooks = true;
                                                setState(() {
                                                  selectUser =
                                                      _getPaginatedUsers()[x];
                                                  carregarEmprestimosUsuario(
                                                      _getPaginatedUsers()[x]
                                                          .idDoUsuario);
                                                });
                                              },
                                              child: const Text('Selecionar',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 250, 244, 244),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                // Paginação
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: currentPageUsers > 1
                                            ? () {
                                                setState(() {
                                                  currentPageUsers--;
                                                });
                                              }
                                            : null,
                                      ),
                                      for (int i = 1;
                                          i <= _getTotalPagesUsers();
                                          i++)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentPageUsers = i;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: i == currentPageUsers
                                                  ? const Color.fromARGB(
                                                      255, 38, 42, 79)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: Text(
                                              i.toString(),
                                              style: TextStyle(
                                                color: i == currentPageUsers
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: currentPageUsers <
                                                _getTotalPagesUsers()
                                            ? () {
                                                setState(() {
                                                  currentPageUsers++;
                                                });
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (selectUser != null)
                          SizedBox(
                            width: 1150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Remova todo o Container com decoração azulada e substitua por:
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            color: Colors.black,
                                            size: 23,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Usuário Selecionado",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.3,
                                                  color: Colors.black,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                        thickness: 2, color: Colors.grey[400]),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Table(
                                      border: TableBorder.all(
                                        color: const Color.fromARGB(
                                            215, 200, 200, 200),
                                      ),
                                      columnWidths: const {
                                        0: FlexColumnWidth(0.08), // Ação
                                        1: FlexColumnWidth(0.42), // Nome
                                        2: FlexColumnWidth(0.15), // Turma
                                        3: FlexColumnWidth(0.15), // Turno
                                        4: FlexColumnWidth(0.32), // Email
                                        5: FlexColumnWidth(
                                            0.15), // Tipo Usuário
                                      },
                                      children: [
                                        const TableRow(
                                          decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(38, 42, 79, 1),
                                          ),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Ação',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Nome',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Turma',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Turno',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Email',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Tipo Usuário',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(
                                                233, 235, 238, 75),
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: IconButton(
                                                icon: const Icon(Icons.history),
                                                tooltip: 'Ver histórico',
                                                iconSize: 18,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 25,
                                                  minHeight: 25,
                                                ),
                                                onPressed: () =>
                                                    _abrirHistoricoUsuario(
                                                        selectUser!),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: Text(
                                                selectUser!.nome,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: Text(
                                                selectUser!.getTurma,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: Text(
                                                selectUser!.getTurno,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: Text(
                                                selectUser!.email,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                              child: Text(
                                                selectUser!.getTipoDeUsuario,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (selectUser != null &&
                                    emprestimos.isNotEmpty)
                                  Column(
                                    children: [
                                      const SizedBox(height: 60),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.library_books,
                                              color: Colors.black,
                                              size: 25,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Exemplares Emprestados",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.3,
                                                    color: Colors.black,
                                                  ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (selectUser != null &&
                                    emprestimos.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Divider(
                                          thickness: 2,
                                          color: Colors.grey[400]),
                                      const SizedBox(height: 10),
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(0.10),
                                          1: FlexColumnWidth(0.26),
                                          2: FlexColumnWidth(0.14),
                                          3: FlexColumnWidth(0.14),
                                          4: FlexColumnWidth(0.08),
                                        },
                                        border: TableBorder.all(
                                          color: const Color.fromARGB(
                                              215, 200, 200, 200),
                                        ),
                                        children: [
                                          const TableRow(
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    38, 42, 79, 1),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Tombamento',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Nome',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text(
                                                      'Data de Empréstimo',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text(
                                                      'Previsão Devolução',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Ação',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                              ]),
                                          for (int x = 0;
                                              x < emprestimos.length;
                                              x++)
                                            TableRow(
                                                decoration: BoxDecoration(
                                                  color: x % 2 == 0
                                                      ? const Color.fromRGBO(
                                                          233, 235, 238, 75)
                                                      : const Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9.4,
                                                        horizontal: 8),
                                                    child: Text(
                                                        emprestimos[x]
                                                            .exemplarMap[
                                                                'IdDoExemplarLivro']
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9.4,
                                                        horizontal: 8),
                                                    child: Text(
                                                        emprestimos[x]
                                                                .exemplarMap[
                                                            'Livro']['Titulo'],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9.4,
                                                        horizontal: 8),
                                                    child: Text(
                                                        emprestimos[x]
                                                            .formatarData(0),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9.4,
                                                        horizontal: 8),
                                                    child: Text(
                                                        emprestimos[x]
                                                            .formatarData(1),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 6,
                                                        horizontal: 37,
                                                      ),
                                                      child: Checkbox(
                                                          value: emprestimos[x]
                                                              .selecionadoRenov,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              emprestimos[x]
                                                                      .selecionadoRenov =
                                                                  value as bool;
                                                            });
                                                          }))
                                                ]),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(0.08),
                                          1: FlexColumnWidth(0.26),
                                          2: FlexColumnWidth(0.14),
                                          3: FlexColumnWidth(0.14),
                                          4: FlexColumnWidth(0.10),
                                        },
                                        children: [
                                          TableRow(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.transparent)),
                                              children: [
                                                const SizedBox.shrink(),
                                                const SizedBox.shrink(),
                                                const SizedBox.shrink(),
                                                const SizedBox.shrink(),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6,
                                                      horizontal: 5),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.orange[400],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                    ),
                                                    onPressed: () {
                                                      List<EmprestimosModel>
                                                          exemplaresSelecionadosRenovacao =
                                                          [];
                                                      for (EmprestimosModel dadosEmprestimo
                                                          in emprestimos) {
                                                        if (dadosEmprestimo
                                                                .selecionadoRenov ==
                                                            true) {
                                                          exemplaresSelecionadosRenovacao
                                                              .add(
                                                                  dadosEmprestimo);
                                                        }
                                                      }
                                                      if (exemplaresSelecionadosRenovacao
                                                          .isNotEmpty)
                                                        renovarExemplares(
                                                            exemplaresSelecionadosRenovacao);
                                                    },
                                                    child: const Text('Renovar',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                )
                                              ])
                                        ],
                                      ),
                                    ],
                                  ),
                                if (emprestimos.isEmpty)
                                  const SizedBox(height: 50),
                                const Divider(),
                              ],
                            ),
                          ),
                        if (showSearchBooks)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Text("Pesquisar Exemplar",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26)),
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 900,
                                          maxHeight: 40,
                                          minWidth: 200),
                                      child: TextField(
                                        controller: _searchControllerBooks,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          labelText:
                                              "Insira o número do tombamento",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                        onSubmitted: (value) {
                                          searchBooks();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            bottom: 16,
                                            left: 16,
                                            right: 20,
                                          ),
                                          backgroundColor: const Color.fromRGBO(
                                              38, 42, 79, 1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onPressed: searchBooks,
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text("Adicionar",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.5)),
                                        ],
                                      )),
                                ],
                              ),
                              const SizedBox(height: 40),
                              if (showBooks)
                                if (selectedBoxExemplar.isNotEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 1150,
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14,
                                                        horizontal: 15),
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.green[400],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8))),
                                                onPressed: () {
                                                  List<Exemplar>
                                                      exemplaresSelecionadosEmprestimo =
                                                      [];
                                                  showLivrosEmprestados;
                                                  for (Exemplar exemplar
                                                      in List.from(
                                                          selectedBoxExemplar)) {
                                                    if (exemplar.checkbox ==
                                                        true) {
                                                      exemplaresSelecionadosEmprestimo
                                                          .add(exemplar);
                                                      selectedBoxExemplar
                                                          .remove(exemplar);
                                                    }
                                                  }
                                                  realizarEmprestimo(
                                                      exemplaresSelecionadosEmprestimo);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.outbox,
                                                      color: Colors.white,
                                                      size: 23,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'Emprestar',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ],
                                                )),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14,
                                                        horizontal: 20),
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.red[400],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8))),
                                                onPressed: () {
                                                  for (Exemplar exemplar
                                                      in List.from(
                                                          selectedBoxExemplar)) {
                                                    if (exemplar.checkbox ==
                                                        true) {
                                                      selectedBoxExemplar
                                                          .remove(exemplar);
                                                    }
                                                  }
                                                  setState(() {});
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                      size: 23,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'Remover',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      SizedBox(
                                        width: 1150,
                                        child: Table(
                                          border: TableBorder.all(
                                              color: const Color.fromARGB(
                                                  215, 200, 200, 200)),
                                          columnWidths: const {
                                            0: FlexColumnWidth(0.05),
                                            1: FlexColumnWidth(0.10),
                                            2: FlexColumnWidth(0.25),
                                            3: FlexColumnWidth(0.12),
                                            4: FlexColumnWidth(0.14),
                                            5: FlexColumnWidth(0.10),
                                          },
                                          children: [
                                            const TableRow(
                                              decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      38, 42, 79, 1)),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Ação',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Tombamento',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Titulo',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Ano de Publicação',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Editora',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Cativo',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: 15)),
                                                ),
                                              ],
                                            ),
                                            for (int x = 0;
                                                x < selectedBoxExemplar.length;
                                                x++)
                                              TableRow(
                                                decoration: BoxDecoration(
                                                    color: x % 2 == 0
                                                        ? const Color.fromRGBO(
                                                            233, 235, 238, 75)
                                                        : const Color.fromRGBO(
                                                            255, 255, 255, 1)),
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Checkbox(
                                                        value:
                                                            selectedBoxExemplar[
                                                                    x]
                                                                .checkbox,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedBoxExemplar[
                                                                        x]
                                                                    .checkbox =
                                                                value!;
                                                          });
                                                        }),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 13,
                                                            bottom: 9,
                                                            left: 8,
                                                            right: 8),
                                                    child: Text(
                                                        selectedBoxExemplar[x]
                                                            .id
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 13,
                                                            bottom: 9,
                                                            left: 8,
                                                            right: 8),
                                                    child: Text(
                                                        selectedBoxExemplar[x]
                                                            .titulo,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 13,
                                                            bottom: 9,
                                                            left: 8,
                                                            right: 8),
                                                    child: Text(
                                                        '${selectedBoxExemplar[x].anoPublicacao}',
                                                        // DateFormat('dd/MM/yyyy').format(
                                                        //     selectedBoxExemplar[x].anoPublicacao
                                                        // ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 13,
                                                            bottom: 9,
                                                            left: 8,
                                                            right: 8),
                                                    child: Text(
                                                        selectedBoxExemplar[x]
                                                            .editora,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 13,
                                                            bottom: 9,
                                                            left: 8,
                                                            right: 8),
                                                    child: Text(
                                                        selectedBoxExemplar[x]
                                                                .cativo
                                                            ? 'Sim'
                                                            : 'Não',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 14.5)),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              const SizedBox(
                                height: 150,
                              )
                            ],
                          ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
