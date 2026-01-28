import 'package:applicazione/viewmodel/statistics_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaticsView extends StatefulWidget {
  const StaticsView({super.key});

  @override
  State<StaticsView> createState() => _StaticsViewState();
}

class _StaticsViewState extends State<StaticsView> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsViewModel>().LoadAllExpenses();
    });
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
          : Padding(
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
                          onChanged: (year) {
                            if (year != null) {
                              setState(() {
                                _selectedYear = year;
                              });
                            }
                          },
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
                            ...<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map(
                              (month) {
                                const monthNames = [
                                  "Gennaio",
                                  "Febbraio",
                                  "Marzo",
                                  "Aprile",
                                  "Maggio",
                                  "Giugno",
                                  "Luglio",
                                  "Agosto",
                                  "Settembre",
                                  "Ottobre",
                                  "Novembre",
                                  "Dicembre",
                                ];
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(monthNames[month - 1]),
                                );
                              },
                            ),
                          ],
                          onChanged: (m) => vm.setMonthFilter(m),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
