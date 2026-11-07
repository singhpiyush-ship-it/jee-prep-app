import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider()..loadData(),
      child: const JEEPrepApp(),
    ),
  );
}

class JEEPrepApp extends StatelessWidget {
  const JEEPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JEE Main 2027 Prep',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E293B),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class AppProvider extends ChangeNotifier {
  List<String> tasks = ['Revise Physics Mechanics', 'Solve 50 Chemistry MCQs', 'Practice Calculus'];
  Map<String, String> chapters = {
    'Physics: Kinematics': 'In Progress',
    'Chemistry: Mole Concept': 'Completed',
    'Maths: Quadratic Eq': 'Not Started',
  };
  List mockTests = [
    {'name': 'Mock Test 1', 'score': 180, 'total': 300, 'date': '2026-03-01'}
  ];

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getString('tasks');
    final savedChapters = prefs.getString('chapters');
    final savedTests = prefs.getString('mockTests');

    if (savedTasks != null) tasks = List<String>.from(jsonDecode(savedTasks));
    if (savedChapters != null) chapters = Map<String, String>.from(jsonDecode(savedChapters));
    if (savedTests != null) mockTests = jsonDecode(savedTests);
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
    await prefs.setString('chapters', jsonEncode(chapters));
    await prefs.setString('mockTests', jsonEncode(mockTests));
  }

  void addTask(String task) {
    tasks.add(task);
    saveData();
    notifyListeners();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    saveData();
    notifyListeners();
  }

  void updateChapter(String chapter, String status) {
    chapters[chapter] = status;
    saveData();
    notifyListeners();
  }

  void addMockTest(String name, int score, int total, String date) {
    mockTests.add({'name': name, 'score': score, 'total': total, 'date': date});
    saveData();
    notifyListeners();
  }

  String exportData() {
    return jsonEncode({
      'tasks': tasks,
      'chapters': chapters,
      'mockTests': mockTests,
    });
  }

  void importData(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      tasks = List<String>.from(data['tasks'] ?? []);
      chapters = Map<String, String>.from(data['chapters'] ?? {});
      mockTests = data['mockTests'] ?? [];
      saveData();
      notifyListeners();
    } catch (e) {
      debugPrint("Import failed: $e");
    }
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const PlannerScreen(),
    const TrackerScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Backup'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime(2027, 1, 15);
    final daysLeft = targetDate.difference(DateTime.now()).inDays;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Target: JEE Main 2027', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Dream Big. Stay Consistent.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF38BDF8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Countdown to Exam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('$daysLeft Days Left', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Keep pushing your limits every single day!', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                int completedChapters = provider.chapters.values.where((v) => v == 'Completed').length;
                return Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending Tasks', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text('${provider.tasks.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Completed Ch.', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text('$completedChapters', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Study Planner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a new target task...',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.all(16)),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      Provider.of<AppProvider>(context, listen: false).addTask(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(provider.tasks[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            onPressed: () => provider.removeTask(index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PCM Chapter Tracker', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return ListView(
                    children: provider.chapters.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.key),
                          trailing: DropdownButton<String>(
                            value: entry.value,
                            dropdownColor: const Color(0xFF1E293B),
                            underline: const SizedBox(),
                            items: ['Not Started', 'In Progress', 'Completed']
                                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                .toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                provider.updateChapter(entry.key, newVal);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  int completed = provider.chapters.values.where((v) => v == 'Completed').length;
                  int inProgress = provider.chapters.values.where((v) => v == 'In Progress').length;
                  int notStarted = provider.
                    
