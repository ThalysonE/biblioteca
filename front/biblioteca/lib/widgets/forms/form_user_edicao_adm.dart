import 'package:biblioteca/data/models/api_response_model.dart';
import 'package:biblioteca/data/models/turma.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/data/services/turmas_service.dart';
import 'package:biblioteca/utils/config.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/forms/campo_obrigatorio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfigPerfil extends StatefulWidget {
  const ConfigPerfil({super.key, required this.usuario});
  final Usuario usuario;

  @override
  State<ConfigPerfil> createState() => _ConfigPerfilState();
}

class _ConfigPerfilState extends State<ConfigPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _formAcessoKey = GlobalKey<FormState>();

  // Controllers para informações pessoais
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  final TextEditingController _turnoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Controllers para dados de acesso
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  final DateTime _today = DateTime.now();
  late AuthProvider authProvider;

  // Variáveis para controle de visualização de senha
  bool _mostrarSenhaAtual = false;
  bool _mostrarNovaSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _isLoading = false;

  final TurmasService _turmasService = TurmasService();
  List<Turma> turmas = [];
  bool showTurmas = false;

  Future<void> _loadTurmas(int turno) async {
    ApiResponse futureTurmas = await _turmasService.fetchTurmas();
    setState(() {
      turmas =
          futureTurmas.body.where((turma) => turma.turno == turno).toList();
      _turmaController.text = turmas[0].turma.toString();
      showTurmas = true;
    });
  }

  Future<void> salvarInformacoesPessoais(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final usuarioProvider =
            Provider.of<UsuarioProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final usuarioAtualizado = Usuario(
          idDoUsuario: widget.usuario.idDoUsuario,
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text.isEmpty
              ? null
              : _telefoneController.text,
          dataDeNascimento: _dateController.text.isEmpty
              ? null
              : DateFormat('d/M/y').parse(_dateController.text),
          cpf: _cpfController.text.isEmpty ? null : _cpfController.text,
          login: widget.usuario.login,
          senha: widget.usuario.senha,
          permissao: widget.usuario.permissao,
          turno: widget.usuario.turno,
          turma: widget.usuario.turma,
        );

        await usuarioProvider.editUsuario(usuarioAtualizado);
        authProvider.uusuario = usuarioAtualizado;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Informações atualizadas com sucesso!")),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("Erro ao atualizar: ${e.toString()}")),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> salvarDadosAcesso(context) async {
    if (_formAcessoKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Verificar se a senha atual está correta (implemente no seu serviço)
        final senhaCorreta = await _verificarSenhaAtual(
            widget.usuario.idDoUsuario, _senhaAtualController.text);

        if (!senhaCorreta) {
          throw Exception("Senha atual incorreta");
        }

        if (_novaSenhaController.text != _confirmarSenhaController.text) {
          throw Exception("As novas senhas não coincidem");
        }

        final usuarioProvider =
            Provider.of<UsuarioProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final usuarioAtualizado = Usuario(
          idDoUsuario: widget.usuario.idDoUsuario,
          nome: widget.usuario.nome,
          email: widget.usuario.email,
          telefone: widget.usuario.telefone,
          dataDeNascimento: widget.usuario.dataDeNascimento,
          cpf: widget.usuario.cpf,
          login: _loginController.text,
          senha: _novaSenhaController.text,
          permissao: widget.usuario.permissao,
          turno: widget.usuario.turno,
          turma: widget.usuario.turma,
        );

        await usuarioProvider.editUsuario(usuarioAtualizado);
        authProvider.uusuario = usuarioAtualizado;

        // Limpar campos de senha
        _senhaAtualController.clear();
        _novaSenhaController.clear();
        _confirmarSenhaController.clear();
      } catch (e) {
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _verificarSenhaAtual(int userId, String senha) async {
    // Implementar uma função no UsuarioService - precisa de um end pint
    return true; // Temporário - substitua pela verificação real
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nomeController.text = widget.usuario.nome;
    _emailController.text = widget.usuario.email;
    _cpfController.text = widget.usuario.cpf ?? '';
    _telefoneController.text = widget.usuario.telefone ?? '';
    _loginController.text = widget.usuario.login;

    if (widget.usuario.dataDeNascimento != null) {
      _dateController.text =
          DateFormat('d/M/y').format(widget.usuario.dataDeNascimento!);
    }
    if (widget.usuario.getTipoDeUsuario == TipoDeUsuario.aluno) {
      _turnoController.text = widget.usuario.turno.toString();
      _loadTurmas(widget.usuario.turno!);
      _turmaController.text = widget.usuario.turma.toString();
      showTurmas = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _dateController.dispose();
    _cpfController.dispose();
    _turmaController.dispose();
    _turnoController.dispose();
    _loginController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const BreadCrumb(
            breadcrumb: ['Início', 'Configurações de Perfil'],
            icon: Icons.co_present_rounded,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seção de Informações Pessoais
                        Form(
                          key: _formKey,
                          child: _buildInformacoesPessoais(),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        // Seção de Dados de Acesso
                        Form(
                          key: _formAcessoKey,
                          child: _buildDadosAcesso(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60.0),
                    _buildBotoesAcao(),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacoesPessoais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Informações Pessoais",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  label: CampoObrigatorio(label: "Nome"),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Preencha esse campo";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  label: CampoObrigatorio(label: "Email"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Preencha esse campo";
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Insira um email válido";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: "CPF",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 11) {
                    return "Insira um CPF válido";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 11) {
                    return "Insira um telefone válido";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Data de Nascimento",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialEntryMode: DatePickerEntryMode.input,
                    locale: const Locale('pt', 'BR'),
                    initialDate: widget.usuario.dataDeNascimento ?? _today,
                    firstDate: DateTime(1900),
                    lastDate: _today,
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text =
                          DateFormat('d/M/y').format(pickedDate);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDadosAcesso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dados do Usuário",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: _loginController,
          decoration: const InputDecoration(
            label: CampoObrigatorio(label: "Login"),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Preencha esse campo";
            }
            return null;
          },
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: _senhaAtualController,
          decoration: InputDecoration(
            labelText: "Senha Atual",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _mostrarSenhaAtual ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _mostrarSenhaAtual = !_mostrarSenhaAtual);
              },
            ),
          ),
          obscureText: !_mostrarSenhaAtual,
          validator: (value) {
            if (_novaSenhaController.text.isNotEmpty &&
                (value == null || value.isEmpty)) {
              return "Necessário para alterar senha";
            }
            return null;
          },
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: _novaSenhaController,
          decoration: InputDecoration(
            labelText: "Nova Senha",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _mostrarNovaSenha ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _mostrarNovaSenha = !_mostrarNovaSenha);
              },
            ),
          ),
          obscureText: !_mostrarNovaSenha,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 6) {
              return "Mínimo 6 caracteres";
            }
            return null;
          },
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: _confirmarSenhaController,
          decoration: InputDecoration(
            labelText: "Confirmar Nova Senha",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _mostrarConfirmarSenha
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(
                    () => _mostrarConfirmarSenha = !_mostrarConfirmarSenha);
              },
            ),
          ),
          obscureText: !_mostrarConfirmarSenha,
          validator: (value) {
            if (_novaSenhaController.text.isNotEmpty &&
                value != _novaSenhaController.text) {
              return "Senhas não coincidem";
            }
            return null;
          },
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        ElevatedButton(
          onPressed: () {
            salvarDadosAcesso(context);
            salvarInformacoesPessoais(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Salvar Informações",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
