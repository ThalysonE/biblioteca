// ignore_for_file: use_build_context_synchronously

import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:biblioteca/widgets/tables/exemplar_table_page.dart';
import 'package:provider/provider.dart';

class BookTablePage extends StatefulWidget {
  const BookTablePage({super.key});

  @override
  BookTablePageState createState() => BookTablePageState();
}

class BookTablePageState extends State<BookTablePage> {
  int rowsPerPage = 10; // Quantidade de linhas por página
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1; // Página atual
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _sortColumn = 'titulo'; // 'titulo', 'isbn', 'editora', 'anoPublicacao'
  bool _isAscending = true;

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      Provider.of<LivroProvider>(context, listen: false).loadLivros().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  });
}

  @override
  @override
Widget build(BuildContext context) {
  LivroProvider livroProvider =
      Provider.of<LivroProvider>(context, listen: true);
      
  if (livroProvider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (livroProvider.hasErrors) {
    return Center(child: Text(livroProvider.error!));
  }
  
  return tableLivro(context);
}

  Material tableLivro(BuildContext context) {
    List<Livro> books = Provider.of<LivroProvider>(context).livros;

    // Filtro de busca
    if (_searchText.isNotEmpty) {
      books = books
          .where((b) =>
              b.titulo.toLowerCase().contains(_searchText) ||
              b.isbn.toLowerCase().contains(_searchText) ||
              b.editora.toLowerCase().contains(_searchText) ||
              b.anoPublicacao.toString().contains(_searchText))
          .toList();
    }

    // Ordenação
    books.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'titulo':
          cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
          break;
        case 'isbn':
          cmp = a.isbn.toLowerCase().compareTo(b.isbn.toLowerCase());
          break;
        case 'editora':
          cmp = a.editora.toLowerCase().compareTo(b.editora.toLowerCase());
          break;
        case 'anoPublicacao':
          cmp = a.anoPublicacao.compareTo(b.anoPublicacao);
          break;
        default:
          cmp = 0;
      }
      return _isAscending ? cmp : -cmp;
    });

    int totalPages = (books.length / rowsPerPage).ceil();

    // Calcula o índice inicial e final dos livros exibidos
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < books.length
        ? (startIndex + rowsPerPage)
        : books.length;

    // Seleciona os livros que serão exibidos na página atual
    List<Livro> paginatedBooks = books.sublist(startIndex, endIndex);

    // Lógica para definir os botões de página (máximo 9 botões)
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Material(
      child: Column(
        children: [
          // Barra de navegação
          const BreadCrumb(
              breadcrumb: ['Início', 'Livros'], icon: Icons.menu_book_outlined),

          // Corpo da página
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
            child: Column(
              // Botão novo livro
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.novoLivro);
                      },
                      label: const Text(
                        'Novo Livro',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.green.shade800),
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(15.0),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(
                  height: 20.0,
                ),

                // Registros por página e campo de Pesquisa
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
                                  value: value, child: Text(value.toString()));
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
                // Tabela de livros
                Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  columnWidths: const {
                    0: FlexColumnWidth(0.40),
                    1: FlexColumnWidth(0.40),
                    2: FlexColumnWidth(0.40),
                    3: FlexColumnWidth(0.40),
                    4: IntrinsicColumnWidth(),
                  },
                  children: [
                    // Cabeçalho da tabela
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 38, 42, 79),
                      ),
                      children: [
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
                        // Editora
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'editora') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'editora';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Editora',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'editora'
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
                        // Ano de Publicação
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'anoPublicacao') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'anoPublicacao';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Ano de Publicação',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'anoPublicacao'
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
                        // Opções
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Opções',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15)),
                        ),
                      ],
                    ),

                    // Linhas da tabela
                    for (int x = 0; x < paginatedBooks.length; x++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: x % 2 == 0
                              ? const Color.fromRGBO(233, 235, 238, 75)
                              : const Color.fromRGBO(255, 255, 255, 1),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedBooks[x].titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5),
                                  textAlign: TextAlign.left),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedBooks[x].isbn,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5),
                                  textAlign: TextAlign.left),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedBooks[x].editora,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  paginatedBooks[x].anoPublicacao.toString(),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        // Caixa de confirmação
                                        final bool? confirm =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Confirmar exclusão'),
                                              content: Text(
                                                  'Tem certeza que deseja excluir o livro "${paginatedBooks[x].titulo}"?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancelar'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Excluir'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          await Provider.of<LivroProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteLivro(
                                                  paginatedBooks[x].idDoLivro);

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Livro excluído com sucesso'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Erro ao excluir livro: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Excluir',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return livroDialog(
                                              context, paginatedBooks[x]);
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 38, 42, 79),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Editar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExemplaresPage(
                                              book: paginatedBooks[x],
                                              ultimaPagina: 'Livros',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Erro ao carregar exemplares: $e'),
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 128, 128, 128),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.library_books_rounded,
                                            color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Exemplares',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Barra de navegação de páginas
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
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
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

  AlertDialog livroDialog(BuildContext context, Livro livro) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _tituloController =
        TextEditingController(text: livro.titulo);
    final TextEditingController _isbnController =
        TextEditingController(text: livro.isbn);
    final TextEditingController _editoraController =
        TextEditingController(text: livro.editora);
    final TextEditingController _anoController =
        TextEditingController(text: livro.anoPublicacao.toString());
    // País, autores e categorias podem ser adaptados conforme necessidade

    return AlertDialog(
      title: const Text('Editar Livro'),
      content: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _isbnController,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _editoraController,
                  decoration: const InputDecoration(
                    labelText: 'Editora',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _anoController,
                  decoration: const InputDecoration(
                    labelText: 'Ano de Publicação',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                // Adicione campos para país, autores e categorias se necessário
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 128, 128, 128),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Extrair nomes dos autores e categorias
              List<String> nomesAutores = [];
              if (livro.autores.isNotEmpty) {
                nomesAutores = livro.autores
                    .map((a) {
                      if (a is Map && a.containsKey('nome')) {
                        return a['nome'].toString();
                      } else if (a is String) {
                        return a;
                      }
                      return '';
                    })
                    .where((nome) => nome.trim().isNotEmpty)
                    .toList()
                    .cast<String>();
              }
              List<String> nomesCategorias = [];
              if (livro.categorias.isNotEmpty) {
                nomesCategorias = livro.categorias
                    .map((c) {
                      if (c is Map && c.containsKey('descricao')) {
                        return c['descricao'].toString();
                      } else if (c is String) {
                        return c;
                      }
                      return '';
                    })
                    .where((nome) => nome.trim().isNotEmpty)
                    .toList()
                    .cast<String>();
              }
              final livroEditado = {
                "Id": livro.idDoLivro,
                "Isbn": _isbnController.text,
                "Titulo": _tituloController.text,
                "AnoPublicacao":
                    int.tryParse(_anoController.text) ?? livro.anoPublicacao,
                "Editora": _editoraController.text,
                "Pais": livro.pais is Map
                    ? livro.pais["idDoPais"] ??
                        livro.pais["IdDoPais"] ??
                        livro.pais
                    : livro.pais,
              };
              await Provider.of<LivroProvider>(context, listen: false)
                  .editLivro(livroEditado, nomesAutores, nomesCategorias);
              await Provider.of<LivroProvider>(context, listen: false)
                  .loadLivros();
              Navigator.of(context).pop();
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 38, 42, 79),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Salvar', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
