// ... other imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expense_tracker_app/provider/exspense_provider.dart';
import 'package:expense_tracker_app/screens/expense_form_screen.dart';
import 'package:expense_tracker_app/widgets/tiles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final selectedDateStr = _selectedDay!.toIso8601String().substring(0, 10);
    final dailyExpenses =
        provider.expenses.where((e) => e.date == selectedDateStr).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchExpenses(),
              child:
                  dailyExpenses.isEmpty
                      ? const Center(child: Text('No expenses for this day 💸'))
                      : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: dailyExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = dailyExpenses[index];
                          return Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              final deleted = expense;
                              final deletedIndex = index;

                              provider.deleteExpense(deleted.id!);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Expense deleted"),
                                  action: SnackBarAction(
                                    label: "Undo",
                                    onPressed: () {
                                      provider.insertExpenseAt(
                                        deleted,
                                        deletedIndex,
                                      );
                                    },
                                  ),
                                ),
                              );

                              await provider.deleteExpense(deleted.id!);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: ExpenseTile(
                              expense: expense,
                              onTap: () async {
                                final updatedExpense = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ExpenseForm(
                                          selectedDate: DateTime.parse(
                                            expense.date,
                                          ),
                                          existingExpense: expense,
                                        ),
                                  ),
                                );

                                if (updatedExpense != null) {
                                  await provider.updateExpense(updatedExpense);
                                  await provider.fetchExpenses();
                                }
                              },
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseForm(selectedDate: _selectedDay!),
            ),
          );

          if (newExpense != null) {
            await provider.addExpense(newExpense);
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0B2956),
      elevation: 0,
      toolbarHeight: 100,
      centerTitle: true,
      title: const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Text(
          'Exspense Tracker',
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              const Text(
                "Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 60,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.grey.shade100,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _calendarFormat == CalendarFormat.month
                      ? "Month View"
                      : "Week View",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _calendarFormat =
                          _calendarFormat == CalendarFormat.month
                              ? CalendarFormat.week
                              : CalendarFormat.month;
                    });
                  },
                  icon: const Icon(Icons.swap_vert),
                  label: const Text("Toggle View"),
                ),
              ],
            ),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarFormat: _calendarFormat,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
