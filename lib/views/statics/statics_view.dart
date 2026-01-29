import 'package:applicazione/utils/color_utils.dart';
import 'package:applicazione/viewmodel/statistics_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaticsView extends StatefulWidget {
  const StaticsView({super.key});

  @override
  State<StaticsView> createState() => _StaticsViewState();
}

class _StaticsViewState extends State<StaticsView> {
  int _selectedYear = DateTime.now().year;
  int _year1 = DateTime.now().year;
  int? _month1;
  int _year2 = DateTime.now().year;
  int? _month2;
  Map<String, dynamic>? _comparison;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsViewModel>().LoadAllExpenses();
    });
  }

  Future<void> _doCompare() async {
    final vm = context.read<StatisticsViewModel>();
    final result = await vm.comparePeriods(_year1, _month1, _year2, _month2);
    setState(() => _comparison = result);
  }

  Widget _buildYearDropdown({required bool isFirst}) {
    final vm = context.watch<StatisticsViewModel>();
    final yearList = vm.allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();
    final selectedYear = isFirst ? _year1 : _year2;
    return DropdownButton<int>(
      value: selectedYear,
      items: yearList
          .map(
            (year) =>
                DropdownMenuItem(value: year, child: Text(year.toString())),
          )
          .toList(),
      onChanged: (year) {
        if (year != null)
          setState(() => isFirst ? _year1 = year : _year2 = year);
      },
    );
  }

  Widget _buildMonthDropdown({required bool isFirst}) {
    final vm = context.watch<StatisticsViewModel>();
    final value = isFirst ? _month1 : _month2;
    return DropdownButton<int>(
      value: value,
      items: [
        const DropdownMenuItem(value: null, child: Text("Tutti i mesi")),
        ...List.generate(
          12,
          (i) => i + 1,
        ).map((m) => DropdownMenuItem(value: m, child: Text(_monthName(m)))),
      ],
      onChanged: (m) {
        if (isFirst)
          _month1 = m;
        else
          _month2 = m;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticsViewModel>();
    final yearList = vm.allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();
    if (!yearList.contains(_selectedYear)) {
      yearList.insert(0, _selectedYear);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche Mensili')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: yearList
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (year) =>
                              setState(() => _selectedYear = year!),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownButton<int?>(
                          value: vm.monthFilter,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Tutti i mesi"),
                            ),
                            ...List.generate(12, (i) => i + 1).map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(_monthName(m)),
                              ),
                            ),
                          ],
                          onChanged: (m) => vm.setMonthFilter(m),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _computerMaxY(vm, _selectedYear),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final totals = vm.calculateMonthlyExpenses(
                                  _selectedYear,
                                );
                                return Text(
                                  totals[v.toInt()]!.toStringAsFixed(0),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) =>
                                  Text(_monthName(v.toInt())),
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        barGroups: vm
                            .calculateMonthlyExpenses(_selectedYear)
                            .entries
                            .map(
                              (e) => BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(toY: e.value, width: 16),
                                ],
                                showingTooltipIndicators: [],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Distribuzione per categoria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (_) {
                      final dataMap = vm.calculateCategoryExpenses(
                        _selectedYear,
                      );
                      if (dataMap.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Nessuna spesa per categoria nel periodo selezionato',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sections: dataMap.entries.map((e) {
                                  final cat = e.key;
                                  return PieChartSectionData(
                                    value: e.value,
                                    title: '${e.value.toStringAsFixed(0)}',
                                    color: parseHexColor(cat.color),
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: dataMap.entries.map((e) {
                              final cat = e.key;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: parseHexColor(cat.color),
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${cat.name}(${e.value.toStringAsFixed(0)}€)',
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),

                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildYearDropdown(isFirst: true)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMonthDropdown(isFirst: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildYearDropdown(isFirst: false)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMonthDropdown(isFirst: false)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _doCompare,
                        child: const Text('Confronta Periodi'),
                      ),
                      const SizedBox(height: 24),
                      if (_comparison != null) ...[
                        Text(
                          'Totale Periodo 1: ${_comparison!['total1'].toStringAsFixed(2)}€',
                        ),
                        Text(
                          'Totale Periodo 2: ${_comparison!['total2'].toStringAsFixed(2)}€',
                        ),
                        Text(
                          'Differenza: ${_comparison!['difference'].toStringAsFixed(2)}€',
                        ),
                        Text(
                          'Variazione %: ${_comparison!['percentChange'].toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  [
                                    _comparison!['period1'] as double,
                                    _comparison!['period2'] as double,
                                  ].reduce((a, b) => a > b ? a : b) *
                                  1.2,
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (x, meta) {
                                      if (x.toInt() == 0)
                                        return const Text('Periodo 1');
                                      else
                                        return const Text('Periodo 2');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),

                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _comparison!['period1'] as double,
                                      width: 30,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _comparison!['period2'] as double,
                                      width: 30,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (r) => false,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  double _computerMaxY(StatisticsViewModel vm, int year) {
    final values = vm.calculateMonthlyExpenses(year).values;
    if (values.isEmpty) return 0;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  static String _monthName(int month) {
    const names = [
      '',
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    return (month >= 1 && month <= 12) ? names[month] : '';
  }
}
