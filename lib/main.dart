import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/health_log_page.dart';
import 'pages/health_insights_page.dart';
import 'pages/medication_reminder_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const VoiceCareApp());
}

class VoiceCareApp extends StatelessWidget {
  const VoiceCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceCare Health Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.yellow[700]!,
          secondary: Colors.amber[600]!,
          surface: Colors.grey[850]!,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late SharedPreferences _prefs;
  double _fontSize = 16.0;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HealthLogPage(),
      const HealthInsightsPage(),
      const MedicationReminderPage(),
      const SettingsPage(),
    ];
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
      _isDarkMode = _prefs.getBool('darkMode') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Provide haptic feedback
            HapticFeedback.lightImpact();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
          selectedItemColor: Colors.yellow[700],
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: _fontSize - 2,
          unselectedFontSize: _fontSize - 4,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article, size: 28),
              activeIcon: Icon(Icons.article, size: 32),
              label: 'Health Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights, size: 28),
              activeIcon: Icon(Icons.insights, size: 32),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication, size: 28),
              activeIcon: Icon(Icons.medication, size: 32),
              label: 'Medications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28),
              activeIcon: Icon(Icons.settings, size: 32),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Splash Screen (optional)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety,
                size: 120,
                color: Colors.yellow[700],
              ),
              const SizedBox(height: 30),
              const Text(
                'VoiceCare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Health Tracking with Voice Assistance',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}