import 'package:biblioteca/data/models/turma.dart';
import 'package:biblioteca/data/providers/turmas_provider.dart';
import 'package:biblioteca/data/turnos_series.dart';
import 'package:biblioteca/widgets/forms/campo_obrigatorio.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TurmasTablePage extends StatefulWidget {
  const TurmasTablePage({super.key});

  @override
  State<TurmasTablePage> createState() => _TurmasTablePageState();
}

class _TurmasTablePageState extends State<TurmasTablePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _turnoController = TextEditingController();
  final TextEditingController _serieController = TextEditingController();

  String _searchText = '';

  int rowsPerPage = 10; // Quantidade de linhas por página
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1; // Página atual

  bool _isInit = true;
  bool _isLoading = false;
  bool _isAscending = true;

  late List<Turma> turmas;

  String _sortColumn = 'descricao';

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<TurmasProvider>(context).loadTurmas().then((_) => {
            setState(() {
              _isLoading = false;
            })
          });
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TurmasProvider turmasProvider = Provider.of<TurmasProvider>(context);
    turmas = context.watch<TurmasProvider>().turma;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (turmasProvider.hasErrors) {
      return Text(turmasProvider.error!);
    } else {
      return getPage(turmasProvider, turmas);
    }
  }

  Future<void> salvarTurma(TurmasProvider turmasProvider) async {
    Turma newTurma = Turma(
                  turma: 0,
                  descricao: _descriptionController.text,
                  serie: int.parse(_serieController.text),
                  turno: int.parse(_turnoController.text));


    await turmasProvider.addTurma(newTurma);


    setState(() {});
  }

  Material getPage(TurmasProvider provider, List<Turma> turmas) {
    if (_searchText.isNotEmpty) {
      turmas = turmas
          .where((c) => c.descricao.toLowerCase().contains(_searchText))
          .toList();
    }

    // Ordenação
    turmas.sort((a, b) {
      return _isAscending
          ? a.descricao.toLowerCase().compareTo(b.descricao.toLowerCase())
          : b.descricao.toLowerCase().compareTo(a.descricao.toLowerCase());
    });

    int totalPages = (turmas.length / rowsPerPage).ceil();

    // Calcula o índice inicial e final dos usuários exibidos
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < turmas.length
        ? (startIndex + rowsPerPage)
        : turmas.length;

    // Seleciona os usuários que serão exibidos na página atual
    List<Turma> paginatedTurmas = turmas.sublist(startIndex, endIndex);

    // Lógica para definir os botões de página (máximo 10 botões)
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
              breadcrumb: ["Início", "Turmas"], icon: Icons.co_present_rounded),

          // Corpo da página
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
            child: Column(
              // Botão novo usuário
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        //Nova categoria
                        showDialog(
                            context: context,
                            builder: (context) {
                              return turmaDialog(context, provider, null);
                            });
                      },
                      label: const Text(
                        'Nova Turma',
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
                          const EdgeInsets.all(15.0), // Padding personalizado
                        ),
                      ),
                    ),
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
                Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  columnWidths: const {
                    0: FlexColumnWidth(0.30),
                    1: FlexColumnWidth(0.17),
                    2: FlexColumnWidth(0.15),
                    3: FlexColumnWidth(0.15),
                    4: FlexColumnWidth(0.17),
                    5: IntrinsicColumnWidth(),
                  },
                  children: [
                    // Cabeçalho da tabela
                    TableRow(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 38, 42, 79)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'descricao') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'descricao';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Turma',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'descricao'
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
                    for (int x = 0; x < paginatedTurmas.length; x++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: x % 2 == 0
                              ? const Color.fromRGBO(233, 235, 238, 75)
                              : const Color.fromRGBO(255, 255, 255, 1),
                        ),
                        children: [
                          Align(
                            alignment: Alignment
                                .centerLeft, // Alinha o texto à esquerda
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                paginatedTurmas[x].descricao,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.5),
                              ), // Alinhamento horizontal
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      //Botão editar
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return turmaDialog(context,
                                                provider, paginatedTurmas[x]);
                                          });
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
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Excluir Categoria'),
                                              content: const Text(
                                                  'Tem certeza que deseja excluir esta turma?'),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              128,
                                                              128,
                                                              128),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Cancelar')),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      //Colocar aqui o deletar
                                                      // provider.deleteCatgoria(
                                                      //     paginatedTurmas[
                                                      //         x]);
                                                      // setState(() {
                                                      //   categories.remove(
                                                      //       paginatedTurmas[
                                                      //           x]);
                                                      // });
                                                      // Navigator.of(context)
                                                      //     .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Confirmar'))
                                              ],
                                            );
                                          });
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
                                  ? const Color.fromARGB(255, 38, 42, 79)
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

  AlertDialog turmaDialog(
      BuildContext context, TurmasProvider turmasProvider, Turma? turma) {
    bool isEdit = false;

    if (turma != null) {
      isEdit = true;
      _descriptionController.text = turma.descricao;
    }

    return AlertDialog(
      title: isEdit ? const Text('Editar Turma') : const Text('Nova Turma'),
      content: SizedBox(
        width: 500,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      label: CampoObrigatorio(label: "Série"),
                      border: OutlineInputBorder(),
                    ),
                    value: _serieController.text.isEmpty
                        ? null
                        : _serieController.text,
                    items: series.map((String serie) {
                      return DropdownMenuItem<String>(
                        value: (series.indexOf(serie) + 1).toString(),
                        child: Text(serie),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _serieController.text = newValue!;
                      // _loadTurmas(int.parse(_serieController.text));
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Selecione a série";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      label: CampoObrigatorio(label: "Turno"),
                      border: OutlineInputBorder(),
                    ),
                    value: _turnoController.text.isEmpty
                        ? null
                        : _turnoController.text,
                    items: turnos.map((String turno) {
                      return DropdownMenuItem<String>(
                        value: (turnos.indexOf(turno) + 1).toString(),
                        child: Text(turno),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _turnoController.text = newValue!;
                      // _loadTurmas(int.parse(_turnoController.text));
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Selecione um turno";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      label: CampoObrigatorio(label: "Descrição"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              )),
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
            child: const Text('Cancelar')),

        //Botão Salvar
        ElevatedButton(
          onPressed: () {
            if (isEdit) {
              // turma!.descricao = _descriptionController.text;
              // turmasProvider.editCatgoria(categoria);
              // setState(() {
              //   categorias
              //       .firstWhere(
              //           (c) => c.idDaCategoria == categoria.idDaCategoria)
              //       .descricao = _descriptionController.text;
              // });
              // Navigator.of(context).pop();
            } else {
              
              salvarTurma(turmasProvider);
              // turmasProvider.addCategoria(_descriptionController.text);
              // turmasProvider.addTurma(newTurma);
              // setState(() {
              // });
              Navigator.of(context).pop();
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
