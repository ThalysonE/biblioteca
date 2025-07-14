import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biblioteca/widgets/tables/exemplar_table_page.dart';

class ObrasPage extends StatefulWidget {
  final Autor autor;
  const ObrasPage({super.key, required this.autor});

  @override
  State<ObrasPage> createState() => _ObrasPageState();
}

class _ObrasPageState extends State<ObrasPage> {
  bool isLoading = true;
  List<Livro> livrosDoAutor = [];

  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _sortColumn = 'titulo'; // 'titulo', 'isbn', 'categoria'
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadLivrosDoAutor();
  }

  Future<void> _loadLivrosDoAutor() async {
    final livrosProvider = Provider.of<LivroProvider>(context, listen: false);
    await livrosProvider.loadLivros();

    livrosDoAutor = livrosProvider.livros
        .where((livro) => livro.autores.any((autor) =>
            autor is Map<String, dynamic> &&
            autor['nome'] == widget.autor.nome))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  String _getCategoriaDescricao(Livro livro) {
    if (livro.categorias.isEmpty) return 'Sem categoria';

    final primeira = livro.categorias.first;

    if (primeira is Map<String, dynamic> && primeira.containsKey('Descricao')) {
      return primeira['Descricao'];
    }

    return 'Sem categoria';
  }

  void _abrirExemplares(Livro livro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExemplaresPage(
          book: livro,
          ultimaPagina: "Autores",
        ),
      ),
    );
  }

  void _sortLivros(String column) {
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
    List<Livro> filteredLivros = livrosDoAutor;
    if (_searchText.isNotEmpty) {
      filteredLivros = filteredLivros
          .where((livro) =>
              livro.titulo.toLowerCase().contains(_searchText) ||
              livro.isbn.toLowerCase().contains(_searchText) ||
              _getCategoriaDescricao(livro).toLowerCase().contains(_searchText))
          .toList();
    }

    // Ordenação
    filteredLivros.sort((a, b) {
      int cmp;
      if (_sortColumn == 'titulo') {
        cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
      } else if (_sortColumn == 'isbn') {
        cmp = a.isbn.toLowerCase().compareTo(b.isbn.toLowerCase());
      } else if (_sortColumn == 'categoria') {
        cmp = _getCategoriaDescricao(a)
            .toLowerCase()
            .compareTo(_getCategoriaDescricao(b).toLowerCase());
      } else {
        cmp = 0;
      }
      return _isAscending ? cmp : -cmp;
    });

    // Paginação
    int totalPages = (filteredLivros.length / rowsPerPage).ceil();
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < filteredLivros.length
        ? (startIndex + rowsPerPage)
        : filteredLivros.length;
    List<Livro> paginatedLivros = filteredLivros.sublist(startIndex, endIndex);

    // Lógica dos botões de página
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Material(
      child: Column(
        children: [
          BreadCrumb(
            breadcrumb: ['Inicio', 'Autores', 'Obras: ${widget.autor.nome}'],
            icon: Icons.menu_book_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Obras de ${widget.autor.nome}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 42, 79),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 40, right: 40),
            child: Row(
              children: [
                const Icon(Icons.menu_book,
                    color: Color.fromARGB(255, 38, 42, 79)),
                const SizedBox(width: 6),
                Text(
                  'Total de obras: ${livrosDoAutor.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 38, 42, 79),
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.category, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  'Categorias: ${livrosDoAutor.map((l) => _getCategoriaDescricao(l)).where((cat) => cat != 'Sem categoria').toSet().length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 38, 42, 79),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
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
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Registros por página
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
                        // Pesquisar
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
                      0: IntrinsicColumnWidth(), // ícone
                      1: FlexColumnWidth(3), // título
                      2: FlexColumnWidth(2), // ISBN
                      3: FlexColumnWidth(2), // categoria
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 38, 42, 79),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Ação',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                          // Título
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (_sortColumn == 'titulo') {
                                    _isAscending = !_isAscending;
                                  } else {
                                    _sortColumn = 'titulo';
                                    _isAscending = true;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Título',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 15),
                                  ),
                                  Icon(
                                    _sortColumn == 'titulo'
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
                          // ISBN
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (_sortColumn == 'isbn') {
                                    _isAscending = !_isAscending;
                                  } else {
                                    _sortColumn = 'isbn';
                                    _isAscending = true;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'ISBN',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 15),
                                  ),
                                  Icon(
                                    _sortColumn == 'isbn'
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
                          // Categoria
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (_sortColumn == 'categoria') {
                                    _isAscending = !_isAscending;
                                  } else {
                                    _sortColumn = 'categoria';
                                    _isAscending = true;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Categoria',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 15),
                                  ),
                                  Icon(
                                    _sortColumn == 'categoria'
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
                        ],
                      ),
                      for (int i = 0; i < paginatedLivros.length; i++)
                        TableRow(
                          decoration: BoxDecoration(
                            color: i % 2 == 0
                                ? const Color.fromRGBO(233, 235, 238, 75)
                                : const Color.fromRGBO(255, 255, 255, 1),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.menu_book),
                                tooltip: 'Ver exemplares',
                                iconSize: 18,
                                constraints: const BoxConstraints(
                                  minWidth: 25,
                                  minHeight: 25,
                                ),
                                onPressed: () =>
                                    _abrirExemplares(paginatedLivros[i]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedLivros[i].titulo),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedLivros[i].isbn),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  _getCategoriaDescricao(paginatedLivros[i])),
                            ),
                          ],
                        ),
                    ],
                  ),
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
