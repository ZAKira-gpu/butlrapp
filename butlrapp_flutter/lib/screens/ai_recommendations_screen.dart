import 'package:flutter/material.dart';
import 'package:butlrapp_client/butlrapp_client.dart';
import '../services/task_service.dart';
import '../services/server_service.dart';
import 'package:intl/intl.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  @override
  Widget build(BuildContext context) {
    final tasks = TaskService().tasks;
    final overdueTasks = TaskService().getOverdueTasks();
    final todayTasks = TaskService().getTasksForDate(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7B61FF),
                    const Color(0xFF9B7FFF),
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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Recommendations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      'Smart insights to boost your productivity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recommendations List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Priority Alert
                  if (overdueTasks.isNotEmpty)
                    _buildRecommendationCard(
                      icon: Icons.warning_rounded,
                      iconColor: const Color(0xFFFF5688),
                      title: 'Overdue Tasks Alert',
                      description: 'You have ${overdueTasks.length} overdue task${overdueTasks.length > 1 ? 's' : ''}. Consider rescheduling or completing them soon.',
                      actionLabel: 'View Tasks',
                      onTap: () {
                        // Navigate to tasks filtered by overdue
                      },
                    ),

                  // Today's Focus
                  if (todayTasks.isNotEmpty)
                    _buildRecommendationCard(
                      icon: Icons.today_rounded,
                      iconColor: const Color(0xFFFFBC6E),
                      title: 'Today\'s Focus',
                      description: 'You have ${todayTasks.length} task${todayTasks.length > 1 ? 's' : ''} scheduled for today. Start with high-priority items first.',
                      actionLabel: 'See Schedule',
                      onTap: () {
                        // Navigate to schedule
                      },
                    ),

                  // Productivity Tip
                  _buildRecommendationCard(
                    icon: Icons.lightbulb_rounded,
                    iconColor: const Color(0xFF67D7ED),
                    title: 'Productivity Tip',
                    description: 'Break large tasks into smaller subtasks. This makes them less overwhelming and easier to complete.',
                    actionLabel: 'Learn More',
                    onTap: () {},
                  ),

                  // Time Management
                  _buildRecommendationCard(
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFF7B61FF),
                    title: 'Optimal Work Time',
                    description: 'Based on your activity, you\'re most productive between 9 AM - 12 PM. Schedule important tasks during this window.',
                    actionLabel: 'Adjust Schedule',
                    onTap: () {},
                  ),

                  // Task Distribution
                  _buildRecommendationCard(
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFFFF5688),
                    title: 'Balance Your Workload',
                    description: 'Consider spreading tasks more evenly across the week to avoid burnout.',
                    actionLabel: 'View Analytics',
                    onTap: () {},
                  ),

                  // Completion Streak
                  _buildRecommendationCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFFBC6E),
                    title: 'Keep Your Streak!',
                    description: 'You\'ve completed tasks for 3 days in a row. Keep it going to build momentum!',
                    actionLabel: 'View Progress',
                    onTap: () {},
                  ),

                  // Smart Scheduling
                  _buildRecommendationCard(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFF9B7FFF),
                    title: 'Smart Scheduling',
                    description: 'AI suggests scheduling your "Learning Dutch" task for weekends when you have more free time.',
                    actionLabel: 'Apply Suggestion',
                    onTap: () {},
                  ),

                  // Break Reminder
                  _buildRecommendationCard(
                    icon: Icons.self_improvement_rounded,
                    iconColor: const Color(0xFF67D7ED),
                    title: 'Take Regular Breaks',
                    description: 'Remember to take a 5-10 minute break every hour to maintain focus and avoid fatigue.',
                    actionLabel: 'Set Reminder',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF313A64),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
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
}
