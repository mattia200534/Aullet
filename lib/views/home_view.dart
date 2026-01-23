import 'package:applicazione/models/category.dart';
import 'package:applicazione/utils/color_utils.dart';
import 'package:applicazione/utils/icon_map.dart';
import 'package:applicazione/viewmodel/category_view_model.dart';
import 'package:applicazione/viewmodel/expense_viewmodel.dart';
import 'package:applicazione/views/new_expense_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewmodel>().loadExpenses();
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseVM = context.watch<ExpenseViewmodel>();
    final catVM = context.watch<CategoryViewModel>();

    return Scaffold(
      body: expenseVM.isLoading || catVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(expenseVM, catVM),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Naviga alla home
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewExpenseView()),
          ).then((_) {
            context.read<ExpenseViewmodel>().loadExpenses();
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody(ExpenseViewmodel expenseVM, CategoryViewModel catVM) {
    final expenses = expenseVM.expenses;
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Non ci sono spese inserite',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Spesa'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewExpenseView()),
                ).then((_) {
                  context.read<ExpenseViewmodel>().loadExpenses();
                });
              },
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final cat = catVM.categories.firstWhere(
          (c) => c.id == exp.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Sconosciuto',
            icon: 'category',
            color: 'FF000000',
            colorHex: '',
          ),
        );
        final iconData = iconMap[cat.icon] ?? Icons.category;
        final color = parseHexColor(cat.color);
        final date = exp.date;
        final formattedDate =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';

        return ListTile(
          leading: Icon(iconData, color: color),
          title: Text(
            '€ ${exp.amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '$formattedDate${exp.description != null && exp.description!.isNotEmpty ? ' \n${exp.description}' : ''}',
          ),
        );
      },
    );
  }
}
