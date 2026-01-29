import 'package:flutter/material.dart';
import 'package:butlrapp_client/butlrapp_client.dart';
import '../services/task_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Calendar Mode State
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();
  late DateTime _anchorDate;
  late ScrollController _dateScrollController;
  List<Task> _calendarTasksState = [];
  bool _isCalendarLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _anchorDate = DateTime.now();
    _dateScrollController = ScrollController(initialScrollOffset: 30 * 82.0); // Start at middle
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TaskService().refreshTasks();
    });
  }

  Future<void> _fetchCalendarTasks() async {
    setState(() {
      _isCalendarLoading = true;
    });
    final tasks = await TaskService().fetchTasksForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _calendarTasksState = tasks;
        _isCalendarLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.animateTo(
          index * 82.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
  }

  List<Task> _getFilteredTasks() {
    List<Task> tasks = TaskService().tasks;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) => 
        task.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply tab filter
    switch (_tabController.index) {
      case 0: // All
        return tasks;
      case 1: // Active
        return tasks.where((task) => !task.completed).toList();
      case 2: // Completed
        return tasks.where((task) => task.completed).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskService(),
      builder: (context, _) {
        final service = TaskService();
        final filteredTasks = _getFilteredTasks();
        final completedCount = service.tasks.where((t) => t.completed).length;
        final totalCount = service.tasks.length;
        final completionRate = totalCount > 0 ? (completedCount / totalCount * 100).toInt() : 0;

        // Smart Grouping Logic (for Overview Mode)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        final overdue = <Task>[];
        final dueToday = <Task>[];
        final dueTomorrow = <Task>[];
        final upcoming = <Task>[];
        final noDate = <Task>[];

        // Use fetched tasks for Calendar Mode
        final calendarTasks = _calendarTasksState;

        if (!_showCalendar) {
           // Original sorting logic for Overview Mode...
           // (This block is skipped in calendar mode so we don't need to do anything here)
          for (final task in filteredTasks) {
            if (task.dueAt == null) {
              noDate.add(task);
            } else {
              final tDate = DateTime(task.dueAt!.year, task.dueAt!.month, task.dueAt!.day);
              if (tDate.isBefore(today)) {
                if (!task.completed) {
                  overdue.add(task);
                } else {
                  dueToday.add(task); 
                }
              } else if (tDate == today) {
                dueToday.add(task);
              } else if (tDate == tomorrow) {
                dueTomorrow.add(task);
              } else {
                upcoming.add(task);
              }
            }
          }
          // Sort groups
          final sortFunc = (Task a, Task b) => (a.dueAt ?? DateTime.now()).compareTo(b.dueAt ?? DateTime.now());
          overdue.sort(sortFunc);
          dueToday.sort(sortFunc);
          dueTomorrow.sort(sortFunc);
          upcoming.sort(sortFunc);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF1F4F9),
          body: SafeArea(
            child: Column(
              children: [
                // Header with Toggle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF313A64),
                        const Color(0xFF313A64).withOpacity(0.85),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  _showCalendar ? 'Schedule' : 'My Tasks',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // View Toggle
                                Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(() => _showCalendar = false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: !_showCalendar ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Icon(
                                            Icons.list_rounded,
                                            size: 18,
                                            color: !_showCalendar ? const Color(0xFF313A64) : Colors.white70,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _showCalendar = true);
                                          _fetchCalendarTasks();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _showCalendar ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Icon(
                                            Icons.calendar_month_rounded,
                                            size: 18,
                                            color: _showCalendar ? const Color(0xFF313A64) : Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$completionRate%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Show Stats ONLY in Overview Mode
                      if (!_showCalendar) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard('Total', totalCount.toString(), Icons.list_alt_rounded),
                            const SizedBox(width: 12),
                            _buildStatCard('Active', (totalCount - completedCount).toString(), Icons.pending_actions_rounded),
                            const SizedBox(width: 12),
                            _buildStatCard('Done', completedCount.toString(), Icons.check_circle_rounded),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Calendar Date Strip (Only valid in Calendar Mode)
                if (_showCalendar) ...[
                  SingleChildScrollView(
                    controller: _dateScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2 - 35
                    ),
                    child: Row(
                      children: List.generate(61, (index) {
                        final date = _anchorDate.add(Duration(days: index - 30));
                        final isSelected = _selectedDate.day == date.day &&
                                         _selectedDate.month == date.month &&
                                         _selectedDate.year == date.year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                            _scrollToIndex(index);
                            _fetchCalendarTasks();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: _buildDatePill(
                              DateFormat('d').format(date),
                              DateFormat('E').format(date),
                              isSelected
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                   // Search Bar (Only in Overview Mode)
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs (Only in Overview Mode)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      indicator: BoxDecoration(
                        color: const Color(0xFF313A64),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF313A64),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Main Task List Area
                Expanded(
                  child: (_showCalendar ? _isCalendarLoading : (service.isLoading && service.tasks.isEmpty))
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (_showCalendar) {
                              await _fetchCalendarTasks();
                            } else {
                              await service.refreshTasks();
                            }
                          },
                          child: filteredTasks.isEmpty && !_showCalendar
                              ? _buildEmptyState()
                              : _showCalendar 
                                      ? ListView( // Calendar View (Flat List)
                                      padding: const EdgeInsets.only(bottom: 100),
                                      children: calendarTasks.isEmpty 
                                        ? [
                                            Padding(
                                              padding: const EdgeInsets.all(40.0),
                                              child: Center(
                                                child: Text(
                                                  'No tasks for this day',
                                                  style: TextStyle(color: Colors.grey[400]),
                                                ),
                                              ),
                                            )
                                          ]
                                        : _buildCalendarList(calendarTasks)
                                          .animate(interval: 50.ms)
                                          .fadeIn()
                                          .slideX(),  
                                    )
                                  : ListView( // Overview View (Grouped List)
                                      padding: const EdgeInsets.only(bottom: 100),
                                      children: [
                                        _buildSection('Overdue', overdue, Colors.redAccent),
                                        _buildSection('Today', dueToday, const Color(0xFF313A64)),
                                        _buildSection('Tomorrow', dueTomorrow, Colors.black87),
                                        _buildSection('Upcoming', upcoming, Colors.grey),
                                        _buildSection('No Date', noDate, Colors.grey),
                                      ]
                                      .animate(interval: 50.ms)
                                      .fadeIn(duration: 300.ms)
                                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                                    ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showAddTaskDialog();
            },
            backgroundColor: const Color(0xFF7B61FF),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Task',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = const Color(0xFFFF5688);
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFFFBC6E);
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF67D7ED);
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.horizontal, // Allow both directions
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          return true;
        } else {
          // Snooze (StartToEnd)
          final originalDate = task.dueAt ?? DateTime.now();
          final newDate = originalDate.add(const Duration(days: 1));
          final updatedTask = task.copyWith(dueAt: newDate);
          
          await TaskService().updateTask(updatedTask);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Snoozed "${task.title}" to tomorrow'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    TaskService().updateTask(task.copyWith(dueAt: originalDate));
                  },
                ),
              ),
            );
          }
          return false; // Don't remove from list (let the stream/refresh handle it moving sections)
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final success = await TaskService().removeTask(task.id!);
          if (success) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${task.title} deleted')),
              );
            }
          }
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.snooze_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _showEditTaskDialog(task);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () async {
                      await TaskService().updateTaskStatus(task.id!, !task.completed);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.completed ? const Color(0xFF313A64) : Colors.transparent,
                        border: Border.all(
                          color: task.completed ? const Color(0xFF313A64) : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: task.completed
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Priority Indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Task Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: task.completed ? Colors.grey[400] : const Color(0xFF313A64),
                                  decoration: task.completed ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (task.recurrence != null) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.repeat_rounded, size: 16, color: Colors.grey[400]),
                            ],
                          ],
                        ),
                        if (task.dueAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, y').format(task.dueAt!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    TaskPriority selectedPriority = task.priority;
    DateTime? selectedDate = task.dueAt;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                    DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                    DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setDialogState(() {
                        // Preserve time if strictly needed, but for now we just use date
                        selectedDate = date;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    selectedDate != null
                        ? DateFormat('MMM d, y').format(selectedDate!)
                        : 'Select due date',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final updatedTask = task.copyWith(
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    priority: selectedPriority,
                    dueAt: selectedDate,
                  );
                  await TaskService().updateTask(updatedTask);
                  if (mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF313A64),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Task> tasks, Color headerColor) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
        ),
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildTaskCard(task),
        )),
      ],
    );
  }

  Widget _buildDatePill(String day, String dayName, bool isSelected) {
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF313A64) : Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF313A64),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarList(List<Task> tasks) {
    if (tasks.isEmpty) return [];

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (!isToday) {
      return tasks.map((t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: _buildTaskCard(t),
      )).toList();
    }

    final List<Widget> widgets = [];
    bool timeIndicatorAdded = false;

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final taskTime = task.dueAt;

      if (!timeIndicatorAdded && taskTime != null) {
         final comparisonDate = DateTime(now.year, now.month, now.day, taskTime.hour, taskTime.minute);
         
         if (comparisonDate.isAfter(now)) {
           widgets.add(_buildTimeIndicator());
           timeIndicatorAdded = true;
         }
      }
      
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: _buildTaskCard(task),
      ));
    }

    if (!timeIndicatorAdded) {
      widgets.add(_buildTimeIndicator());
    }

    return widgets;
  }

  Widget _buildTimeIndicator() {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              timeString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: Colors.redAccent,
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    // Pre-fill date if in Calendar mode
    DateTime? selectedDate = _showCalendar ? _selectedDate : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Task title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                  DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                  DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() {
                      selectedDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  selectedDate != null
                      ? DateFormat('MMM d, y').format(selectedDate!)
                      : 'Select due date',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final newTask = Task(
                    title: titleController.text,
                    priority: selectedPriority,
                    dueAt: selectedDate,
                    completed: false,
                    createdAt: DateTime.now(),
                  );
                  await TaskService().addTask(newTask);
                  if (mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF313A64),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
