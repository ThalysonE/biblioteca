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

  @override
  Widget build(BuildContext context) {
    final exemplarProvider = Provider.of<ExemplarProvider>(context);
    final exemplaresDoLivro = exemplarProvider.exemplares
        .where((ex) => ex.idLivro == widget.book.idDoLivro)
        .toList();

    return Material(
      child: Column(
        children: [
          BreadCrumb(
            breadcrumb: ['Inicio', widget.ultimaPagina, 'Exemplares'],
            icon: Icons.menu_book_outlined,
          ),
          if (isLoading)
            const CircularProgressIndicator()
          else
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
              child: Column(
                children: [
                  Text("Total de exemplares: ${exemplaresDoLivro.length}"),
                  Table(
                    border: TableBorder.all(
                      color: const Color.fromARGB(255, 213, 213, 213),
                    ),
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: IntrinsicColumnWidth(),
                    },
                    children: [
                      const TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Exemplar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'ISBN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Ações',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      // Linhas da tabela
                      for (int i = 0;
                          i < exemplarProvider.exemplares.length;
                          i++)
                        if (exemplarProvider.exemplares[i].idLivro ==
                            widget.book.idDoLivro)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${exemplarProvider.exemplares[i].id}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text(exemplarProvider.exemplares[i].isbn),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  value: exemplarProvider.exemplares[i].estado
                                      .toString(),
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
                                  onChanged: (newValue) {
                                    setState(() {
                                      exemplarProvider.exemplares[i] = Exemplar(
                                        id: exemplarProvider.exemplares[i].id,
                                        cativo: exemplarProvider
                                            .exemplares[i].cativo,
                                        statusCodigo: exemplarProvider
                                            .exemplares[i].statusCodigo,
                                        estado: int.parse(newValue!),
                                        ativo: exemplarProvider
                                            .exemplares[i].ativo,
                                        idLivro: exemplarProvider
                                            .exemplares[i].idLivro,
                                        isbn:
                                            exemplarProvider.exemplares[i].isbn,
                                        titulo: exemplarProvider
                                            .exemplares[i].titulo,
                                        anoPublicacao: exemplarProvider
                                            .exemplares[i].anoPublicacao,
                                        editora: exemplarProvider
                                            .exemplares[i].editora,
                                        idPais: exemplarProvider
                                            .exemplares[i].idPais,
                                        nomePais: exemplarProvider
                                            .exemplares[i].nomePais,
                                        siglaPais: exemplarProvider
                                            .exemplares[i].siglaPais,
                                      );
                                    });
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
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
                              ),
                            ],
                          ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      ExemplarEnvio novoExemplar = ExemplarEnvio(
                        id: 0,
                        idLivro: widget.book.idDoLivro,
                        cativo: false,
                        status: 0,
                        estado: 0,
                        ativo: true,
                      );

                      await Provider.of<ExemplarProvider>(context,
                              listen: false)
                          .addExemplar(novoExemplar);
                      await _loadExemplares();
                    },
                    label: const Text(
                      'Novo Exemplar',
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
            ),
        ],
      ),
    );
  }
}
