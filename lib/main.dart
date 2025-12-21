import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitch_perfect_flutter/clubdirectory/screens/club_directory_page.dart';
import 'package:pitch_perfect_flutter/forum/screens/menu.dart';
import 'package:pitch_perfect_flutter/profile/screens/profile_page.dart';
import 'package:pitch_perfect_flutter/statistics/screens/statistics_home.dart';
import 'package:pitch_perfect_flutter/matchprediction/screens/matchprediction_main.dart';
import 'package:pitch_perfect_flutter/profile/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CookieRequest>(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'PitchPerfect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 1. COLOR PALETTE (International White & Navy)
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E293B), // Navy (Slate 800)
            secondary: Color(0xFFF97316), // Orange
            surface: Color(0xFFF8FAFC), // Ultra Light Grey (Slate 50)
            background: Color(0xFFF8FAFC),
            onSurface: Color(0xFF1E293B),
          ),

          // 2. TYPOGRAPHY (The Secret Sauce)
          textTheme: TextTheme(
            // Headers = Orbitron (Futuristic/Sports)
            displayLarge: GoogleFonts.orbitron(fontWeight: FontWeight.w900, letterSpacing: -1.0, color: const Color(0xFF1E293B)),
            displayMedium: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: const Color(0xFF1E293B)),
            displaySmall: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            headlineMedium: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),

            // Body = Lato (Clean/Readable)
            bodyLarge: GoogleFonts.lato(fontSize: 16, color: const Color(0xFF334155)),
            bodyMedium: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF475569)),
            labelLarge: GoogleFonts.tektur(fontWeight: FontWeight.bold), // Buttons
          ),

          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),

          // 3. COMPONENT THEMES
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: const Color(0xFF1E293B),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.tektur(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ClubDirectoryPage(),
    const StatisticsHomePage(),
    const MatchPredictionMain(),
    const ForumHomePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // UNIVERSAL NAVBAR (Kept as requested)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFF97316),
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.tektur(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold),
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Directory'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Matches'),
            BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}