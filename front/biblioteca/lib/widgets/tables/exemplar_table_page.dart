import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExemplaresPage extends StatefulWidget {
  final Livro book;
  final String ultimaPagina;

  const ExemplaresPage(
      {super.key, required this.book, required this.ultimaPagina});

  @override
  State<ExemplaresPage> createState() => _ExemplaresPageState();
}

class _ExemplaresPageState extends State<ExemplaresPage> {
  bool isLoading = true;

  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _sortColumn = 'id'; // 'id', 'situacao', 'estado', 'cativo'
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadExemplares();
  }

  Future<void> _loadExemplares() async {
    final provider = Provider.of<ExemplarProvider>(context, listen: false);
    await provider.loadExemplares();
    setState(() {
      isLoading = false;
    });
  }

  void _sortExemplares(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exemplarProvider = Provider.of<ExemplarProvider>(context);
    final exemplaresDoLivro = exemplarProvider.exemplares
        .where((ex) => ex.idLivro == widget.book.idDoLivro && ex.ativo == true)
        .toList();

    // Filtro de busca
    List<Exemplar> filteredExemplares = exemplaresDoLivro;
    if (_searchText.isNotEmpty) {
      filteredExemplares = filteredExemplares.where((ex) {
        final idMatch = ex.id.toString().contains(_searchText);
        final situacaoMatch = ex.getStatus.toLowerCase().contains(_searchText);
        final estadoMatch = ex.getEstado.toLowerCase().contains(_searchText);
        final cativoMatch = (ex.cativo ? 'sim' : 'não').contains(_searchText) ||
            (ex.cativo ? 'sim' : 'nao')
                .contains(_searchText); // cobre "não" e "nao"
        return idMatch || situacaoMatch || estadoMatch || cativoMatch;
      }).toList();
    }

    // Ordenação
    filteredExemplares.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'id':
          cmp = a.id.compareTo(b.id);
          break;
        case 'situacao':
          cmp = a.getStatus.compareTo(b.getStatus);
          break;
        case 'estado':
          cmp = a.getEstado.compareTo(b.getEstado);
          break;
        case 'cativo':
          cmp = (a.cativo ? 1 : 0).compareTo(b.cativo ? 1 : 0);
          break;
        default:
          cmp = a.id.compareTo(b.id);
      }
      return _isAscending ? cmp : -cmp;
    });

    // Paginação
    int totalPages = (filteredExemplares.length / rowsPerPage).ceil();
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < filteredExemplares.length
        ? (startIndex + rowsPerPage)
        : filteredExemplares.length;
    List<Exemplar> paginatedExemplares =
        filteredExemplares.sublist(startIndex, endIndex);

    // Contadores
    int disponiveis =
        exemplaresDoLivro.where((e) => e.statusCodigo == 1).length;
    int emprestados =
        exemplaresDoLivro.where((e) => e.statusCodigo == 0).length;
    int indisponiveis =
        exemplaresDoLivro.where((e) => e.statusCodigo == 2).length;
    int bons = exemplaresDoLivro.where((e) => e.estado == 1).length;
    int danificados = exemplaresDoLivro.where((e) => e.estado == 2).length;

    // Autores (label dinâmica: "Autor(a)" ou "Autores")
    String autoresLabel = '';
    String autores = '';
    if (widget.book.autores.isNotEmpty) {
      final nomes = widget.book.autores
          .map((a) {
            if (a is Map<String, dynamic> && a.containsKey('nome')) {
              return a['nome'];
            } else if (a is String) {
              return a;
            }
            return '';
          })
          .where((nome) => nome != null && nome.toString().trim().isNotEmpty)
          .toList();
      autores = nomes.join(', ');
      autoresLabel = nomes.length > 1 ? 'Autores' : 'Autor(a)';
    }

    // Paginação
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Material(
      child: Column(
        children: [
          BreadCrumb(
            breadcrumb: ['Inicio', widget.ultimaPagina, 'Exemplares'],
            icon: Icons.menu_book_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.titulo,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 38, 42, 79),
                    ),
                  ),
                  if (autores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '$autoresLabel: $autores',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.library_books,
                          color: Color.fromARGB(255, 38, 42, 79)),
                      const SizedBox(width: 6),
                      Text(
                        'Total: ${exemplaresDoLivro.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Disponíveis: $disponiveis',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.assignment_returned,
                          color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Emprestados: $emprestados',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        'Indisponíveis: $indisponiveis',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.thumb_up, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        'Bons: $bons',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.thumb_down, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Danificados: $danificados',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    ExemplarEnvio novoExemplar = ExemplarEnvio(
                      id: 0,
                      idLivro: widget.book.idDoLivro,
                      cativo: false,
                      status: 1,
                      estado: 1,
                      ativo: true,
                    );
                    await Provider.of<ExemplarProvider>(context, listen: false)
                        .addExemplar(novoExemplar);
                    await _loadExemplares();
                  },
                  label: const Text(
                    'Novo Exemplar',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.green.shade800),
                    foregroundColor: const WidgetStatePropertyAll(Colors.white),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
              child: Column(
                children: [
                  // Paginação e registros por página
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Exibir'),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: rowsPerPage,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    rowsPerPage = value;
                                    currentPage = 1;
                                  });
                                }
                              },
                              items: rowsPerPageOptions.map((int value) {
                                return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()));
                              }).toList(),
                            ),
                            const SizedBox(width: 8),
                            const Text('registros por página'),
                          ],
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Pesquisar',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchText = value.toLowerCase();
                                currentPage = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200),
                    ),
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: IntrinsicColumnWidth(),
                      5: IntrinsicColumnWidth(),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                        children: [
                          // Exemplar
                          InkWell(
                            onTap: () => _sortExemplares('id'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'Tombamento',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    _sortColumn == 'id'
                                        ? (_isAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward)
                                        : Icons.unfold_more,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Situação
                          InkWell(
                            onTap: () => _sortExemplares('situacao'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'Situação',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    _sortColumn == 'situacao'
                                        ? (_isAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward)
                                        : Icons.unfold_more,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Estado
                          InkWell(
                            onTap: () => _sortExemplares('estado'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'Estado',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    _sortColumn == 'estado'
                                        ? (_isAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward)
                                        : Icons.unfold_more,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Cativo
                          InkWell(
                            onTap: () => _sortExemplares('cativo'),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'Cativo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    _sortColumn == 'cativo'
                                        ? (_isAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward)
                                        : Icons.unfold_more,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Ações
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Ações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0; i < paginatedExemplares.length; i++)
                        TableRow(
                          decoration: BoxDecoration(
                            color: i % 2 == 0
                                ? const Color.fromRGBO(233, 235, 238, 75)
                                : const Color.fromRGBO(255, 255, 255, 1),
                          ),
                          children: [
                            // Exemplar
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${paginatedExemplares[i].id}'),
                            ),
                            // Situação
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                paginatedExemplares[i].statusCodigo == 1
                                    ? 'Disponível'
                                    : 'Emprestado',
                              ),
                            ),
                            // Estado
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton<String>(
                                value: paginatedExemplares[i].estado.toString(),
                                isDense: true,
                                menuMaxHeight: 150,
                                underline: Container(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                onChanged: (newValue) async {
                                  final novoExemplar = Exemplar(
                                    id: paginatedExemplares[i].id,
                                    cativo: paginatedExemplares[i].cativo,
                                    statusCodigo:
                                        paginatedExemplares[i].statusCodigo,
                                    estado: int.parse(newValue!),
                                    ativo: paginatedExemplares[i].ativo,
                                    idLivro: paginatedExemplares[i].idLivro,
                                    isbn: paginatedExemplares[i].isbn,
                                    titulo: paginatedExemplares[i].titulo,
                                    anoPublicacao:
                                        paginatedExemplares[i].anoPublicacao,
                                    editora: paginatedExemplares[i].editora,
                                    idPais: paginatedExemplares[i].idPais,
                                    nomePais: paginatedExemplares[i].nomePais,
                                    siglaPais: paginatedExemplares[i].siglaPais,
                                  );
                                  setState(() {
                                    paginatedExemplares[i] = novoExemplar;
                                  });
                                  await exemplarProvider
                                      .alterExemplar(novoExemplar);
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: '0',
                                    child: Text('Selecionar'),
                                  ),
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Bom'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Danificado'),
                                  ),
                                ],
                              ),
                            ),
                            // Cativo
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                paginatedExemplares[i].cativo == true
                                    ? 'Sim'
                                    : 'Não',
                              ),
                            ),
                            // Botão de apagar
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                label: const Text('Apagar',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmar exclusão'),
                                        content: Text(
                                            'Tem certeza que deseja apagar o exemplar de ID ${paginatedExemplares[i].id}?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Apagar'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirm == true) {
                                    try {
                                      await exemplarProvider.deleteExemplar(
                                          paginatedExemplares[i].id);
                                      await _loadExemplares();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Exemplar apagado com sucesso'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Erro ao apagar exemplar: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Paginação
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                        ),
                        for (int i = startPage; i <= endPage; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = i;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: i == currentPage
                                    ? Color.fromARGB(255, 38, 42, 79)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                i.toString(),
                                style: TextStyle(
                                  color: i == currentPage
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () {
                                  setState(() {
                                    currentPage++;
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
        ],
      ),
    );
  }
}
