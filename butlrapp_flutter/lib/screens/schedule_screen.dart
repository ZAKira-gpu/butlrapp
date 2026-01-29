import 'dart:async';
import 'package:flutter/material.dart';
import 'package:butlrapp_client/butlrapp_client.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import 'package:flutter_animate/flutter_animate.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _anchorDate = DateTime.now();
  final ScrollController _dateScrollController = ScrollController();
  late Timer _timer;

  List<Task> _dayTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    TaskService().addListener(_fetchTasks);
    
    // Update UI every minute to move position line
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });

    // Scroll to "Today" (index 30) after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.jumpTo(30 * 82.0);
      }
    });
  }

  @override
  void dispose() {
    TaskService().removeListener(_fetchTasks);
    _timer.cancel();
    _dateScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final tasks = await TaskService().fetchTasksForDate(_selectedDate);
    
    if (mounted) {
      setState(() {
        _dayTasks = tasks;
        _isLoading = false;
         // Sort by time
        _dayTasks.sort((a, b) => (a.dueAt ?? DateTime.now()).compareTo(b.dueAt ?? DateTime.now()));
      });
    }
  }

  void _scrollToIndex(int index) {
    // With padding set to (screen/2 - item/2), offset 0 centers index 0.
    // So to center index N, we just scroll N * itemWidth.
    const itemWidth = 82.0; 
    final offset = index * itemWidth;
    
    _dateScrollController.animateTo(
      offset, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF313A64), size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('MMMM, d').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF313A64),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('✍️', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_dayTasks.length} task${_dayTasks.length == 1 ? '' : 's'} today',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF313A64), size: 24),
                      onPressed: _pickDate,
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Date Selector
            const SizedBox(height: 10),
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
                      _fetchTasks();
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

            // Scrollable Timeline Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTasks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ongoing',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              _buildPriorityDot(const Color(0xFF67D7ED), size: 10),
                              const SizedBox(width: 8),
                              _buildPriorityDot(const Color(0xFFFFBC6E), size: 14),
                              const SizedBox(width: 8),
                              _buildPriorityDot(const Color(0xFFFF5688), size: 18),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Timeline Items
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_dayTasks.isEmpty)
                        _buildEmptyState()
                      else
                        ..._buildWithTimeIndicator(_dayTasks)
                            .map((w) => w.animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildWithTimeIndicator(List<Task> tasks) {
    if (tasks.isEmpty) return [];

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (!isToday) {
      return tasks.map((t) => _buildTaskTimelineItem(t)).toList();
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
      
      widgets.add(_buildTaskTimelineItem(task));
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
      padding: const EdgeInsets.only(bottom: 20.0, left: 70),
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

  Widget _buildDatePill(String day, String weekday, bool isSelected) {
    return Container(
      width: 70,
      height: 110,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF313A64) : Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weekday,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white.withOpacity(0.8) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No tasks for this day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTimelineItem(Task task) {
    final time = task.dueAt != null ? DateFormat('h:mm a').format(task.dueAt!) : 'All day';
    
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Dismissible(
              key: Key('schedule_${task.id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) async {
                await TaskService().updateTaskStatus(task.id!, true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${task.title} completed')),
                  );
                }
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 28),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: priorityColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.priority.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (task.completed)
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      ],
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
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF313A64), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _anchorDate = picked; // Update anchor to center list around new date
      });
      _fetchTasks();
      // Reset scroll to center
      if (_dateScrollController.hasClients) {
         _dateScrollController.jumpTo(30 * 82.0);
      }
    }
  }

  Widget _buildPriorityDot(Color color, {double size = 12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
