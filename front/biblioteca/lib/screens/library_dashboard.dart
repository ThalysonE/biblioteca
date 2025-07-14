import 'package:biblioteca/data/providers/dashboard_provider.dart';
import 'package:biblioteca/data/providers/auth_provider.dart';
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
  int loansToday = 0;
  int returnsToday = 0;
  int delaysToday = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboard(auth.idDaSessao, auth.usuarioLogado);
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    final DateTime now = DateTime.now();

    final DateTime sunday = now.subtract(Duration(days: now.weekday % 7));

    final List<String> weekDays = List.generate(7, (index) {
      final DateTime date = sunday.add(Duration(days: index));
      return DateFormat('EEE, dd/MM', 'pt_BR').format(date);
    });

    // Índice do dia atual (domingo = 0, segunda = 1, ..., sábado = 6)
    final int todayIndex = now.weekday % 7;

    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        if (dashProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dashProvider.error != null) {
          return Center(child: Text(dashProvider.error!));
        }
        final dashboard = dashProvider.dashboard;
        if (dashboard == null) {
          return const Center(child: Text('Nenhum dado disponível.'));
        }

        // Monta os dados do gráfico a partir do banco
        final List<FlSpot> loanSpots = List.generate(
            7,
            (i) => FlSpot(
                i.toDouble(), dashboard.qtdEmprestimoSemana[i].toDouble()));
        final List<FlSpot> returnSpots = List.generate(
            7,
            (i) => FlSpot(
                i.toDouble(), dashboard.qtdDevolucaoSemana[i].toDouble()));
        final List<FlSpot> delaySpots = List.generate(
            7,
            (i) => FlSpot(i.toDouble(),
                dashboard.qtdLivrosAtrasadosSemana[i].toDouble()));

        // Calcula o valor máximo do eixo Y com base nos dados
        final double maxY = [
          ...loanSpots,
          ...returnSpots,
          ...delaySpots,
        ].map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
        final double adjustedMaxY = maxY > 10 ? maxY : 10;

        return Material(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              return Column(
                children: [
                  const BreadCrumb(breadcrumb: ["Início"], icon: Icons.home),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SummaryCards(
                          loansToday: dashboard.qtdEmprestimoSemana[todayIndex],
                          returnsToday:
                              dashboard.qtdDevolucaoSemana[todayIndex],
                          delaysToday:
                              dashboard.qtdLivrosAtrasadosSemana[todayIndex],
                          onReportsPressed: () {
                            Navigator.of(context).push(
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
                            _buildLineChartData(
                              loanSpots,
                              returnSpots,
                              delaySpots,
                              adjustedMaxY,
                              weekDays,
                              isSmallScreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
              } else {
                return const SizedBox.shrink();
              }
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
