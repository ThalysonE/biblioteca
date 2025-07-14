class DashboardModel {
  final List<int> qtdEmprestimoSemana;
  final List<int> qtdDevolucaoSemana;
  final List<int> qtdLivrosAtrasadosSemana;

  DashboardModel({
    required this.qtdEmprestimoSemana,
    required this.qtdDevolucaoSemana,
    required this.qtdLivrosAtrasadosSemana,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      qtdEmprestimoSemana: List<int>.from(json['QtdEmprestimoSemana']),
      qtdDevolucaoSemana: List<int>.from(json['QtdDevolucaoSemana']),
      qtdLivrosAtrasadosSemana:
          List<int>.from(json['QtdLivrosAtrasadosSemana']),
    );
  }
}
