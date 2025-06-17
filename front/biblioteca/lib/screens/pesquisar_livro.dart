
import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PesquisarLivro extends StatefulWidget {
  const PesquisarLivro({super.key});

  @override
  State<PesquisarLivro> createState() => _PesquisarLivroState();
}

class _PesquisarLivroState extends State<PesquisarLivro> {
  late TextEditingController _searchController;
  late List<Livro> filteredBooks = [];
  late Livro? selectBook;
  late bool search = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }
  scafoldMsg(String msg, int tipo){
    return ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            backgroundColor: tipo == 1? Colors.red: (tipo ==2)? Colors.orange: Colors.green,
            content: Text(
              msg,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ));
  }

  Future<List<Exemplar>> searchExemplares(int idDoLivro) async{
    List<Exemplar> exemplaresLivro = [];
    try{
      final response = await Provider.of<ExemplarProvider>(context, listen: false).fetchExemplaresIdLivro(idDoLivro);
      exemplaresLivro = response;
      return exemplaresLivro;
    }catch(e){
      print(e.toString());
      return [];
    }
  }

  Future<void> searchBooks()async{
    final seachQuery = _searchController.text.trim(); 
    selectBook = null;
    if(seachQuery.isNotEmpty){
      try{
        final resposta = await Provider.of<LivroProvider>(context, listen: false).searchLivros(seachQuery);
        filteredBooks = resposta;
        try{
          await Future.wait([
            for(final x in filteredBooks) () async{
              final exemplares = await searchExemplares(x.idDoLivro);
              x.listaExemplares = exemplares;
            }()
          ]);
        }catch(e){
            scafoldMsg('Erro ao carregar os exemplares dos livro', 1);
        }
        setState(() {
          search = true;
        });
      }catch(e){
        print(e.toString());
        scafoldMsg('Erro ao realizar a pesquisa de livros. Tente novamente mais tarde.', 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Material(
      child: Column(
        children: [
          const BreadCrumb(
              breadcrumb: ['Início', 'Pesquisar Livro'], icon: Icons.search),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesquisa De Livro",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 800,
                          maxHeight: 40,
                          minWidth: 200,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Insira os dados do livro",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: searchBooks,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Pesquisar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.5,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (filteredBooks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum livro encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectBook == null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1210,
                              minWidth: 900,
                            ),
                            child: Table(
                              border: TableBorder.all(
                                color: const Color.fromARGB(215, 200, 200, 200),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(0.13),
                                1: FlexColumnWidth(0.30),
                                2: FlexColumnWidth(0.20),
                                3: FlexColumnWidth(0.14),
                                4: FlexColumnWidth(0.10),
                                5: FlexColumnWidth(0.13),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 44, 62, 80),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'ISBN',
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
                                        'Titulo',
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
                                        'Autor',
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
                                        'Ano de Publicação',
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
                                        'Qtd. Exemplares',
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
                                        'Ação',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                for (int x = 0; x < filteredBooks.length; x++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: x % 2 == 0
                                          ? const Color.fromRGBO(233, 235, 238, 75)
                                          : const Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13, horizontal: 8),
                                        child: Text(
                                          filteredBooks[x].isbn,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13, horizontal: 8),
                                        child: Text(
                                          filteredBooks[x].titulo,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13, horizontal: 8),
                                        child: Text(
                                          filteredBooks[x].autores[0]["nome"],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13, horizontal: 8),
                                        child: Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            filteredBooks[x].anoPublicacao,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13, horizontal: 8),
                                        child: Text(
                                          filteredBooks[x].listaExemplares.length.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 5,
                                        ),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 45, 106, 79),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectBook = filteredBooks[x];
                                            });
                                          },
                                          child: const Text(
                                            'Selecionar',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 250, 244, 244),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: 1150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(230, 227, 242, 253),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 8, right: 8, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.book,
                                                color: Color.fromARGB(
                                                    255, 46, 125, 50),
                                                size: 23,
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                "Livro Selecionado",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.3,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                            thickness: 2,
                                            color: Colors.grey[400]),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Table(
                                          border: TableBorder.all(
                                            color: const Color.fromARGB(
                                                215, 200, 200, 200),
                                          ),
                                          columnWidths: const {
                                            0: FlexColumnWidth(0.07),
                                            1: FlexColumnWidth(0.13),
                                            2: FlexColumnWidth(0.30),
                                            3: FlexColumnWidth(0.20),
                                            4: FlexColumnWidth(0.14),
                                            5: FlexColumnWidth(0.10),
                                          },
                                          children: [
                                            const TableRow(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 44, 62, 80),
                                              ),
                                              children: [
                                                SizedBox.shrink(),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'ISBN',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Titulo',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Autor',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Ano de Publicação',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Qtd. Exemplares',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Icon(
                                                    Icons.menu_book_outlined,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Text(
                                                    selectBook!.isbn,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:const  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Text(
                                                    selectBook!.titulo,
                                                    textAlign: TextAlign.left,
                                                    style:const  TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:const  EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Text(
                                                    selectBook!.autores[0]['nome'],
                                                    textAlign: TextAlign.center,
                                                    style:const  TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Text(
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(
                                                      selectBook!.anoPublicacao,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8),
                                                  child: Text(
                                                    selectBook!.listaExemplares.length.toString(),
                                                    textAlign: TextAlign.center,
                                                    style:const  TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.library_books,
                                        color: Color.fromARGB(255, 46, 125, 50),
                                        size: 24,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "Detalhes Dos Exemplares",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.3,
                                              color: Colors.black,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(thickness: 2, color: Colors.grey[400]),
                                const SizedBox(
                                  height: 10,
                                ),
                                Table(
                                  border: TableBorder.all(
                                    color: const Color.fromARGB(
                                        215, 200, 200, 200),
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.12),
                                    1: FlexColumnWidth(0.30),
                                    2: FlexColumnWidth(0.16),
                                    3: FlexColumnWidth(0.15),
                                    4: FlexColumnWidth(0.10),
                                  },
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 44, 62, 80),
                                      ),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Tombamento',
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
                                            'Titulo',
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
                                            'Situação',
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
                                            'Estado Físico',
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
                                            'Cativo',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (int x = 0;
                                        x < selectBook!.listaExemplares.length;
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: Text(
                                              selectBook!.listaExemplares[x]
                                                  .id
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14.5),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: Text(
                                              selectBook!.listaExemplares[x].titulo,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14.5),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 3),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  selectBook!.listaExemplares[x]
                                                              .statusCodigo ==
                                                          1
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: selectBook!.listaExemplares[x]
                                                              .statusCodigo ==
                                                          1
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    selectBook!.listaExemplares[x]
                                                        .getStatus,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: Text(
                                              selectBook!.listaExemplares[x].getEstado,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14.5),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: Text(
                                              selectBook!.listaExemplares[x].cativo? 'Sim':'Não',
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
                          ),
                          const SizedBox(
                            height: 40,
                          )
                      ],
                    )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
