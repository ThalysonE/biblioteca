class TipoDeStatus {
  //status 0: emprestado
  //status 1: diponivel
  //status 2: indisponivel
  static const disponivel = "Disponível";
  static const emprestado = "Emprestado";
  static const indisponivel = "Indisponível";
}

class TipoEstado {
  //1 - Bom
  //0 - Danificado
  static const bom = "Bom";
  static const danificado = "Danificado";
}

class ExemplarEnvio {
  final int id;
  final int idLivro;
  final bool cativo;
  final int status;
  final int estado;
  final bool ativo;

  ExemplarEnvio(
      {required this.id,
      required this.idLivro,
      required this.cativo,
      required this.status,
      required this.estado,
      required this.ativo});

  String get getStatus =>
      status == 1 ? TipoDeStatus.disponivel : status == 0? TipoDeStatus.emprestado: TipoDeStatus.indisponivel;
  String get getEstado => estado == 1 ? TipoEstado.bom : TipoEstado.danificado;

  factory ExemplarEnvio.fromJson(Map<String, dynamic> json) {
    return ExemplarEnvio(
      id: json['IdDoExemplarLivro'],
      idLivro: json['IdDoLivro'],
      cativo: json['Cativo'],
      status: json['Status'],
      estado: json['Estado'],
      ativo: json['Ativo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdDoExemplarLivro': id,
      'Cativo': cativo,
      'Status': status,
      'Estado': estado,
      'Ativo': ativo,
      'IdDoLivro': idLivro,
    };
  }
}

class Exemplar {
  final int id;
  final bool cativo;
  final int statusCodigo;
  final int estado;
  final bool ativo;
  final int idLivro;
  final String isbn;
  final String titulo;
  final int anoPublicacao;
  final String editora;
  final int idPais;
  final String nomePais;
  final String siglaPais;
  bool checkbox =
      true; // usado somente para controlar a seleção do exemplar no empréstimo

  Exemplar({
    required this.id,
    required this.cativo,
    required this.statusCodigo,
    required this.estado,
    required this.ativo,
    required this.idLivro,
    required this.isbn,
    required this.titulo,
    required this.anoPublicacao,
    required this.editora,
    required this.idPais,
    required this.nomePais,
    required this.siglaPais,
  });

  String get getStatus =>
      statusCodigo == 1 ? TipoDeStatus.disponivel : statusCodigo == 0? TipoDeStatus.emprestado: TipoDeStatus.indisponivel;
  String get getEstado => estado == 1 ? TipoEstado.bom : TipoEstado.danificado;

  factory Exemplar.fromJson(Map<String, dynamic> json) {
    return Exemplar(
      id: json['IdDoExemplarLivro'],
      cativo: json['Cativo'],
      statusCodigo: json['Status'],
      estado: json['Estado'],
      ativo: json['Ativo'],
      idLivro: json['IdDoLivro'],
      isbn: json['Isbn'],
      titulo: json['Titulo'],
      anoPublicacao: json['AnoPublicacao'],
      editora: json['Editora'],
      idPais: json['IdDoPais'],
      nomePais: json['NomePais'],
      siglaPais: json['SiglaPais'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdDoExemplarLivro': id,
      'Cativo': cativo,
      'Status': statusCodigo,
      'Estado': estado,
      'Ativo': ativo,
      'IdDoLivro': idLivro,
      'Isbn': isbn,
      'Titulo': titulo,
      'AnoPublicacao': anoPublicacao,
      'Editora': editora,
      'IdDoPais': idPais,
      'NomePais': nomePais,
      'SiglaPais': siglaPais,
    };
  }
}
