import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/providers/emprestimo_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:biblioteca/screens/telas_testes.dart';
import 'package:biblioteca/widgets/dashboard/summary_cards.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:provider/provider.dart';
class LibraryDashboard extends StatefulWidget {
  const LibraryDashboard({super.key});

  @override
  State<LibraryDashboard> createState() => _LibraryDashboardState();
}

class _LibraryDashboardState extends State<LibraryDashboard> {

  // Simulação...
  int loansToday = 0;
  int returnsToday = 0;
  int delaysToday = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodosEmprestimos();
  }
  calcularOsDadosDashBoard(){
    //calcular os emprestimos de hoje
    final hoje = DateTime.now();
    final dataHojeFormatada= DateTime(hoje.year, hoje.month, hoje.day);
    
    int qtdEmprestimosHoje = emprestimos.where((item){
      final data = DateFormat('yyyy-MM-dd').parse(item.dataEmprestimo);
      final dataFormatada = DateTime(data.year, data.month, data.day);
      return dataHojeFormatada == dataFormatada;
    }).length;
    //calcular os empresprestimos em atraso
    int qtdEmprestimosAtrasados = emprestimos.where((item){
      final data = DateFormat('yyyy-MM-dd').parse(item.dataPrevistaEntrega);
      final dataFormatada = DateTime(data.year, data.month, data.day);
      return dataHojeFormatada.isAfter(dataFormatada);
    }).length;
    
    //devolucao de hoje
    int qtdEmprestimsDevolvidosHoje = emprestimos.where((item){
      final data = DateFormat('yyyy-MM-dd').parse(item.dataDeDevolucao);
      final dataFormatada = DateTime(data.year, data.month, data.day);
      return (dataFormatada == dataHojeFormatada) && (item.status == 3 ||item.status == 2);
    }).length;
    setState(() {
      loansToday = qtdEmprestimosHoje;
      returnsToday = qtdEmprestimsDevolvidosHoje;
      delaysToday = qtdEmprestimosAtrasados;
    });
  }
  List<EmprestimosModel> emprestimos = [];
    Future<void> fetchTodosEmprestimos () async{
      try{
        final resposta = await Provider.of<EmprestimoProvider>(context, listen: false).fetchTodosEmprestimos();
        emprestimos = resposta;
        calcularOsDadosDashBoard();
      }catch(e){
        print('Erro ao carregar os emprestimos: ${e.toString()}');
      }
      setState(() {
        emprestimos;
      });
  }
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    final List<String> weekDays = List.generate(7, (index) {
      final DateTime date = monday.add(Duration(days: index));
      return DateFormat('EEE, dd/MM', 'pt_BR').format(date);
    });
    

    final List<FlSpot> loanSpots = [
      const FlSpot(0, 8), // Segunda
      const FlSpot(1, 0), // Terça
      const FlSpot(2, 5), // Quarta
      const FlSpot(3, 1), // Quinta
      const FlSpot(4, 10), // Sexta
      const FlSpot(5, 0), // Sábado
      const FlSpot(6, 0), // Domingo
    ];

    final List<FlSpot> returnSpots = [
      const FlSpot(0, 0), // Segunda
      const FlSpot(1, 7), // Terça
      const FlSpot(2, 0), // Quarta
      const FlSpot(3, 6), // Quinta
      const FlSpot(4, 4), // Sexta
      const FlSpot(5, 0), // Sábado
      const FlSpot(6, 0), // Domingo
    ];

    final List<FlSpot> delaySpots = [
      const FlSpot(0, 2), // Segunda
      const FlSpot(1, 1), // Terça
      const FlSpot(2, 3), // Quarta
      const FlSpot(3, 2), // Quinta
      const FlSpot(4, 3), // Sexta
      const FlSpot(5, 5), // Sábado
      const FlSpot(6, 6), // Domingo
    ];

    // Calcula o valor máximo do eixo Y com base nos dados
    final double maxY = [
      ...loanSpots,
      ...returnSpots,
      ...delaySpots,
    ].map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Define o valor mínimo do eixo Y como 10 se o valor máximo for menor que 10, senão mantém o valor máximo
    final double adjustedMaxY = maxY > 10 ? maxY : 10;

    return Material(
      // LayoutBuilder ajuda a adaptar o layout para diferentes tamanhos de tela e bla bla bla
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return SingleChildScrollView(
            child: Column(
              children: [
                const BreadCrumb(breadcrumb: ["Início"], icon: Icons.home),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      SummaryCards(
                        loansToday: loansToday,
                        returnsToday: returnsToday,
                        delaysToday: delaysToday,
                        onReportsPressed: () {
                          // Navega para a tela de relatórios
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Relatorios(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 150),
                      AspectRatio(
                        aspectRatio: isSmallScreen ? 1 : 4,
                        child: LineChart(
                          _buildLineChartData(loanSpots, returnSpots, delaySpots,
                              adjustedMaxY, weekDays, isSmallScreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Configuração do gráfico
  LineChartData _buildLineChartData(
    List<FlSpot> loanSpots,
    List<FlSpot> returnSpots,
    List<FlSpot> delaySpots,
    double maxY,
    List<String> weekDays,
    bool isSmallScreen,
  ) {
    return LineChartData(
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // Empréstimos
        LineChartBarData(
          spots: loanSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
          preventCurveOverShooting: true,
        ),
        // Devoluções
        LineChartBarData(
          spots: returnSpots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 4,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
          preventCurveOverShooting: true,
        ),
        // Atrasos
        LineChartBarData(
          spots: delaySpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
          preventCurveOverShooting: true,
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value % 1 == 0) {
                return Text(value.toInt().toString());
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Quantidade',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          axisNameSize: 24,
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return const SizedBox.shrink();
            },
            reservedSize: 24,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              if (value.toInt() < weekDays.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    weekDays[value.toInt()],
                    style: style,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        topTitles: AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Movimentações Diárias',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          axisNameSize: 30,
          sideTitles: const SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
    );
  }
}
