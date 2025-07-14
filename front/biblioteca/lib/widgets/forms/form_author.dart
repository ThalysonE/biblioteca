import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/models/paises_model.dart';
import 'package:biblioteca/data/models/sexo_model.dart';
import 'package:biblioteca/data/providers/autor_provider.dart';
import 'package:biblioteca/data/providers/paises_provider.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/widgets/forms/campo_obrigatorio.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// const List<String> paises = <String>['Brasil', 'Estados Unidos', 'Reino Unido'];

class FormAutor extends StatefulWidget {
  const FormAutor({super.key, this.autor});
  final Autor? autor;

  @override
  State<FormAutor> createState() => _FormAutorState();
}

class _FormAutorState extends State<FormAutor> {
  bool isModoEdicao() {
    return widget.autor != null;
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nacionalidadeController =
      TextEditingController();
  final TextEditingController _sexoController = TextEditingController();

  List<Pais> _paises = [];

  Future<void> loadPaises() async {
    PaisesProvider paisesProvider =
        Provider.of<PaisesProvider>(context, listen: false);

    await paisesProvider.loadPaises();

    setState(() {
      _paises = paisesProvider.paises;
    });
  }

  void btnSalvar(context) async {
    AutorProvider provider = Provider.of<AutorProvider>(context, listen: false);
    final Autor newAutor;
    String? mensagem = '';

    if (isModoEdicao()) {
      newAutor = widget.autor!;

      newAutor.nome = _nomeController.text;
      newAutor.nacionalidadeCodigo =
          int.tryParse(_nacionalidadeController.text);
      newAutor.sexoCodigo = _sexoController.text;

      await provider.editAutor(newAutor);

      mensagem = provider.hasErrors
          ? "Ocorreu um erro ao tentar alterar este registro, por favor confira os dados inseridos"
          : "Registro alterado com sucesso";
    } else {
      newAutor = Autor(
          nome: _nomeController.text,
          nacionalidadeCodigo: int.tryParse(_nacionalidadeController.text),
          sexoCodigo: _sexoController.text);

      await provider.addAutor(newAutor);

      mensagem = provider.hasErrors
          ? provider.error
          : "Cadastro realizado com sucesso";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(mensagem!),
          backgroundColor: provider.hasErrors ? Colors.red : Colors.green),
    );

    if (!provider.hasErrors) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.autores, ModalRoute.withName(AppRoutes.home));
    }
  }

  @override
  void initState() {
    loadPaises();

    if (isModoEdicao()) {
      _nomeController.text = widget.autor!.nome;

      _nacionalidadeController.text = widget.autor!.nacionalidadeCodigo != null
          ? widget.autor!.nacionalidadeCodigo.toString()
          : '';

      _sexoController.text =
          widget.autor!.sexoCodigo != null ? widget.autor!.sexoCodigo! : '';
    }

    super.initState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nacionalidadeController.dispose();
    _sexoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de navegação
        const BreadCrumb(
            breadcrumb: ['Início', 'Autores', 'Novo Autor'],
            icon: Icons.menu_book_outlined),
        // Formulário
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          label: CampoObrigatorio(label: "Nome"),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Preencha esse campo";
                          } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s.'’]+$")
                              .hasMatch(value)) {
                            return "O nome deve conter apenas letras";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),


                      // Nacionalidade
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Nacionalidade",
                          border: OutlineInputBorder(),
                        ),
                        value: _nacionalidadeController.text.isEmpty
                            ? null
                            : _nacionalidadeController.text,
                        items: _paises.map((Pais pais) {
                          return DropdownMenuItem<String>(
                            value: pais.idDoPais.toString(),
                            child: Text(pais.nome),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          _nacionalidadeController.text = newValue!;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Sexo
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Sexo",
                          border: OutlineInputBorder(),
                        ),
                        value: _sexoController.text.isEmpty
                            ? null
                            : _sexoController.text,
                        items: sexos.map((Sexo sexo) {
                          return DropdownMenuItem<String>(
                            value: sexo.codigo,
                            child: Text(sexo.sexo),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          _sexoController.text = newValue!;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Botões
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cancelar
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),

                          // Salvar
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                btnSalvar(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Salvar",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
