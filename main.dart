
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // ADD THIS LINE AT THE TOP
//import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js_unsafe;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HackathonApp());
}

// ============================================================
// CONFIGURATION
// ============================================================
const String STAFF_ID = 'wondersofai';
const String STAFF_PASSWORD = 'yuvejkumar';

// ============================================================
// HELPER EXTENSION (Prevents crashes on missing fields)
// ============================================================
extension DocumentSnapshotExtension on DocumentSnapshot {
  dynamic safeGet(String field, [dynamic defaultValue]) {
    try {
      final mapData = data() as Map<String, dynamic>?;
      if (mapData != null && mapData.containsKey(field)) {
        return mapData[field] ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}

// ============================================================
// THEME
// ============================================================
class AppColors {
  static const Color primaryRed = Color(0xFFB8000A);
  static const Color darkRed = Color(0xFF6B0000);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF16161F);
  static const Color cardDark = Color(0xFF1F1F2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF3D00);
  static const Color info = Color(0xFF00B0FF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB8000A), Color(0xFF6B0000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF16161F), Color(0xFF1A0505)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class HackathonApp extends StatelessWidget {
  const HackathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonders of AI - Euphoria 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primaryRed,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryRed,
          secondary: AppColors.accentGold,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primaryRed.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentGold, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const LandingPage(),
    );
  }
}

// ============================================================
// ROCKET LOADER ANIMATION
// ============================================================
class RocketLoader extends StatefulWidget {
  final String text;
  const RocketLoader({super.key, this.text = 'Loading...'});

  @override
  State<RocketLoader> createState() => _RocketLoaderState();
}

class _RocketLoaderState extends State<RocketLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _ctrl,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch,
                  color: Colors.black, size: 35),
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.text,
              style: const TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        ],
      ),
    );
  }
}

// ============================================================
// LANDING PAGE - Portal Selection
// ============================================================
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildOrgBadge('KARE OSS'),
                    _buildOrgBadge('INFOZIANT'),
                    _buildOrgBadge('CSI'),
                    _buildOrgBadge('IEEE'),
                    _buildOrgBadge('OWASP'),
                    _buildOrgBadge('CYBERNERDS'),
                  ],
                ),
                const SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'WONDERS',
                    style: TextStyle(
                      fontSize: isMobile ? 42 : 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      height: 1,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.goldGradient.createShader(bounds),
                  child: Text(
                    'OF AI',
                    style: TextStyle(
                      fontSize: isMobile ? 42 : 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '⚡ 24 HOURS HACKATHON ⚡',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'EUPHORIA 2026 • 25-26 September 2026',
                  style: TextStyle(color: AppColors.accentGold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'CHOOSE YOUR PORTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildPortalCard(
                              context,
                              icon: Icons.person,
                              title: 'Participant Portal',
                              subtitle: 'Access for participants and leaders.',
                              color: AppColors.primaryRed,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ParticipantLogin())),
                            ),
                            const SizedBox(height: 16),
                            _buildPortalCard(
                              context,
                              icon: Icons.rate_review,
                              title: 'Reviewer Panel',
                              subtitle: 'Grade teams and evaluate projects.',
                              color: AppColors.info,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const StaffLogin(
                                          role: 'Reviewer'))),
                            ),
                            const SizedBox(height: 16),
                            _buildPortalCard(
                              context,
                              icon: Icons.admin_panel_settings,
                              title: 'Admin Console',
                              subtitle: 'Central management of hackathon.',
                              color: AppColors.accentGold,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const StaffLogin(role: 'Admin'))),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildPortalCard(
                                context,
                                icon: Icons.person,
                                title: 'Participant Portal',
                                subtitle:
                                    'Access for participants and leaders.',
                                color: AppColors.primaryRed,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ParticipantLogin())),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildPortalCard(
                                context,
                                icon: Icons.rate_review,
                                title: 'Reviewer Panel',
                                subtitle: 'Grade teams and evaluate projects.',
                                color: AppColors.info,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const StaffLogin(
                                            role: 'Reviewer'))),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildPortalCard(
                                context,
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Console',
                                subtitle: 'Central management of hackathon.',
                                color: AppColors.accentGold,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const StaffLogin(role: 'Admin'))),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accentGold.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Text('🏆 Prize Pool: ₹1,00,000 + Internships',
                          style: TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('R&D Conference Hall, KARE',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrgBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.accentGold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Icon(Icons.arrow_forward, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STAFF LOGIN (Handles Admin & Reviewer)
// ============================================================
class StaffLogin extends StatefulWidget {
  final String role; // 'Admin' or 'Reviewer'
  const StaffLogin({super.key, required this.role});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController pwdCtrl = TextEditingController();
  bool obscurePwd = true;
  bool isLoading = false;
  String? errorMsg;

  void _login() {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (idCtrl.text.trim() == STAFF_ID &&
          pwdCtrl.text.trim() == STAFF_PASSWORD) {
        if (widget.role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ReviewerDashboard()),
          );
        }
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'Invalid credentials. Please try again.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReviewer = widget.role == 'Reviewer';
    final themeColor = isReviewer ? AppColors.info : AppColors.accentGold;
    final icon = isReviewer ? Icons.rate_review : Icons.admin_panel_settings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: themeColor.withOpacity(0.4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: RocketLoader(text: 'Authenticating...'),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themeColor.withOpacity(0.2),
                                  border: Border.all(color: themeColor),
                                ),
                                child: Icon(icon, size: 40, color: themeColor),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '${widget.role} Login',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Enter your official credentials',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: idCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: '${widget.role} ID',
                                  prefixIcon:
                                      Icon(Icons.person, color: themeColor),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: pwdCtrl,
                                obscureText: obscurePwd,
                                style: const TextStyle(color: Colors.white),
                                onSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      Icon(Icons.lock, color: themeColor),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePwd
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                        () => obscurePwd = !obscurePwd),
                                  ),
                                ),
                              ),
                              if (errorMsg != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            AppColors.error.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: AppColors.error, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorMsg!,
                                          style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _login,
                                  icon: const Icon(Icons.login),
                                  label: const Text('Login',
                                      style: TextStyle(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                    foregroundColor: themeColor ==
                                            AppColors.accentGold
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PARTICIPANT LOGIN (Google Sign In)
// ============================================================
class ParticipantLogin extends StatefulWidget {
  const ParticipantLogin({super.key});

  @override
  State<ParticipantLogin> createState() => _ParticipantLoginState();
}

class _ParticipantLoginState extends State<ParticipantLogin> {
  bool isLoading = false;

    Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      if (kIsWeb) {
        // Direct Firebase Web Popup (100% safe & works on all browsers)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile fallback
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => isLoading = false);
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParticipantAuthWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParticipantAuthWrapper()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppColors.primaryRed.withOpacity(0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: RocketLoader(text: 'Signing In...'),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryRed
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person,
                                    size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Participant Login',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign in with your Google account',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: signInWithGoogle,
                                  icon: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.g_mobiledata,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  label: const Text(
                                    'Continue with Google',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.warning.withOpacity(0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber,
                                        color: AppColors.warning, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Only Team Leaders should register the team',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PARTICIPANT AUTH WRAPPER
// ============================================================
class ParticipantAuthWrapper extends StatelessWidget {
  const ParticipantAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: RocketLoader());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const LandingPage();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('teams')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: RocketLoader());
            }
            if (docSnap.hasData && docSnap.data!.exists) {
              return const ParticipantDashboard();
            }
            return RegistrationScreen(user: snapshot.data!);
          },
        );
      },
    );
  }
}

// ============================================================
// REGISTRATION SCREEN
// ============================================================
class RegistrationScreen extends StatefulWidget {
  final User user;
  const RegistrationScreen({super.key, required this.user});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final teamNameCtrl = TextEditingController();
  final leaderNameCtrl = TextEditingController();
  final leaderPhoneCtrl = TextEditingController();
  final collegeCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final yearCtrl = TextEditingController();

  List<Map<String, TextEditingController>> members = [];
  bool isSubmitting = false;

  void addMember() {
    if (members.length < 4) {
      setState(() {
        members.add({
          'name': TextEditingController(),
          'email': TextEditingController(),
          'phone': TextEditingController(),
        });
      });
    } else {
      _showSnack('Maximum 5 members (including leader)', AppColors.warning);
    }
  }

  void removeMember(int i) => setState(() => members.removeAt(i));

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));

    try {
      final memberData = members
          .map((m) => {
                'name': m['name']!.text,
                'email': m['email']!.text,
                'phone': m['phone']!.text,
              })
          .toList();

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.user.uid)
          .set({
        'teamName': teamNameCtrl.text.trim(),
        'leaderName': leaderNameCtrl.text.trim(),
        'leaderEmail': widget.user.email,
        'leaderPhone': leaderPhoneCtrl.text.trim(),
        'college': collegeCtrl.text.trim(),
        'department': departmentCtrl.text.trim(),
        'year': yearCtrl.text.trim(),
        'members': memberData,
        'roomNumber': 'Not Assigned',
        'seatNumber': 'Not Assigned',
        'problemStatement': 'Not Assigned',
        'problemStatementTitle': 'Not Assigned',
        'isPresent': false,
        'round1Completed': false,
        'round2Completed': false,
        'round3Completed': false,
        'scores': {},
        'registeredAt': FieldValue.serverTimestamp(),
      });
      _showSnack('Registration Successful!', AppColors.success);
    } catch (e) {
      _showSnack('Error: $e', AppColors.error);
    }
    if (mounted) setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Registration'),
        backgroundColor: AppColors.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: isSubmitting
            ? const RocketLoader(text: 'Registering Team...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                      Icons.groups, 'Team & Leader Details'),
                                  const SizedBox(height: 16),
                                  _tf(teamNameCtrl, 'Team Name *', Icons.badge),
                                  const SizedBox(height: 12),
                                  _tf(leaderNameCtrl, 'Leader Name *',
                                      Icons.person),
                                  const SizedBox(height: 12),
                                  _tf(
                                      leaderPhoneCtrl,
                                      'Leader Phone *',
                                      Icons.phone,
                                      keyboardType: TextInputType.phone),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.success
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified,
                                            color: AppColors.success),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                  'Leader Email (Google)',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontSize: 12)),
                                              Text(widget.user.email ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _tf(collegeCtrl, 'College *', Icons.school),
                                  const SizedBox(height: 12),
                                  _tf(departmentCtrl, 'Department *',
                                      Icons.business),
                                  const SizedBox(height: 12),
                                  _tf(yearCtrl, 'Year of Study *',
                                      Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _sectionHeader(Icons.group_add,
                                            'Team Members (${members.length}/4)'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: addMember,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accentGold,
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (members.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceDark,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.people_outline,
                                              size: 40,
                                              color: AppColors.textSecondary),
                                          SizedBox(height: 8),
                                          Text('No members added',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary)),
                                        ],
                                      ),
                                    )
                                  else
                                    ...members.asMap().entries.map((e) =>
                                        _memberCard(e.key, e.value)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: submit,
                              icon: const Icon(Icons.rocket_launch),
                              label: const Text('COMPLETE REGISTRATION',
                                  style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGold,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryRed, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ],
    );
  }

  Widget _tf(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentGold),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _memberCard(int idx, Map<String, TextEditingController> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryRed,
                radius: 16,
                child: Text('${idx + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text('Member ${idx + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => removeMember(idx),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _tf(m['name']!, 'Full Name', Icons.person_outline),
          const SizedBox(height: 10),
          _tf(m['email']!, 'Email', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _tf(m['phone']!, 'Phone', Icons.phone_outlined,
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }
}

// ============================================================
// PARTICIPANT DASHBOARD (Mobile-Responsive)
// ============================================================
class ParticipantDashboard extends StatefulWidget {
  const ParticipantDashboard({super.key});

  @override
  State<ParticipantDashboard> createState() => _ParticipantDashboardState();
}

class _ParticipantDashboardState extends State<ParticipantDashboard> {
  int selectedIndex = 0;

  final tabs = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.assignment, 'label': 'Problem'},
    {'icon': Icons.timeline, 'label': 'Rounds'},
    {'icon': Icons.groups, 'label': 'Team'},
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LandingPage();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text('Participant Portal',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const RocketLoader();
            }
            if (!snapshot.data!.exists) {
              return const Center(
                child: Text('No team data found',
                    style: TextStyle(color: Colors.white)),
              );
            }

            final data = snapshot.data!;
            switch (selectedIndex) {
              case 0:
                return _dashboardTab(data);
              case 1:
                return _problemTab(data);
              case 2:
                return _roundsTab(data);
              case 3:
                return _teamTab(data);
              default:
                return _dashboardTab(data);
            }
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.primaryRed.withOpacity(0.3)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => setState(() => selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accentGold,
          unselectedItemColor: AppColors.textSecondary,
          items: tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t['icon'] as IconData),
                    label: t['label'] as String,
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ---- Dashboard tab ----
  Widget _dashboardTab(DocumentSnapshot data) {
    final isPresent = data.safeGet('isPresent', false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'Team ${data.safeGet('teamName', 'Unknown')} 🚀',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Leader: ${data.safeGet('leaderName', '')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('25-26 September 2026',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _statCard(
            icon: Icons.room,
            label: 'Room Number',
            value: data.safeGet('roomNumber', 'Not Assigned'),
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _statCard(
            icon: Icons.chair,
            label: 'Seat Number',
            value: data.safeGet('seatNumber', 'Not Assigned'),
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _statCard(
            icon: isPresent ? Icons.check_circle : Icons.pending,
            label: 'Attendance',
            value: isPresent ? 'PRESENT ✓' : 'PENDING',
            color: isPresent ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: AppColors.accentGold),
                      SizedBox(width: 8),
                      Text('Quick Info',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: AppColors.textSecondary),
                  _infoRow(Icons.email, 'Email',
                      data.safeGet('leaderEmail', '')),
                  _infoRow(Icons.phone, 'Phone',
                      data.safeGet('leaderPhone', '')),
                  _infoRow(Icons.school, 'College',
                      data.safeGet('college', 'N/A')),
                  _infoRow(Icons.business, 'Department',
                      data.safeGet('department', 'N/A')),
                  _infoRow(Icons.calendar_today, 'Year',
                      data.safeGet('year', 'N/A')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _liveRoundStatusCard(data),
          const SizedBox(height: 16),
          _timelineCard(),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 18),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _liveRoundStatusCard(DocumentSnapshot data) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('settings')
          .doc('global')
          .snapshots(),
      builder: (context, snap) {
        Map<String, dynamic> settings = {};
        if (snap.hasData && snap.data!.exists) {
          settings = snap.data!.data() as Map<String, dynamic>;
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline, color: AppColors.primaryRed),
                    const SizedBox(width: 8),
                    const Text('Round Status',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(color: AppColors.textSecondary),
                _roundTile('Round 1', 'Ideation',
                    settings['round1Status'] ?? 'pending',
                    data.safeGet('round1Completed', false)),
                const SizedBox(height: 8),
                _roundTile('Round 2', 'Development',
                    settings['round2Status'] ?? 'pending',
                    data.safeGet('round2Completed', false)),
                const SizedBox(height: 8),
                _roundTile('Round 3', 'Final',
                    settings['round3Status'] ?? 'pending',
                    data.safeGet('round3Completed', false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _roundTile(
      String name, String subtitle, String status, bool completed) {
    Color color;
    String text;
    IconData icon;
    if (completed) {
      color = AppColors.success;
      text = 'COMPLETED ✓';
      icon = Icons.check_circle;
    } else if (status == 'ended') {
      color = AppColors.error;
      text = 'ENDED';
      icon = Icons.stop_circle;
    } else if (status == 'started') {
      color = AppColors.warning;
      text = 'IN PROGRESS';
      icon = Icons.play_circle;
    } else {
      color = AppColors.textSecondary;
      text = 'NOT STARTED';
      icon = Icons.pending;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

        Widget _timelineCard() {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('settings')
              .doc('timeline')
              .snapshots(),
          builder: (context, snap) {
            List events = [];

            if (snap.hasData && snap.data!.exists) {
              final data = snap.data!.data() as Map<String, dynamic>?;
              events = List.from(data?['events'] ?? []);
            }

            // If nothing in Firebase → show "Will update"
            if (events.isEmpty) {
              events = [
                {'time': 'Will update', 'event': 'Schedule will be updated soon'},
              ];
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.info),
                        SizedBox(width: 8),
                        Text('Event Timeline',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: AppColors.textSecondary),
                    ...events.map((e) {
                      final time = (e['time'] ?? 'Will update').toString();
                      final event = (e['event'] ?? 'Will update').toString();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(event,
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            Text(time,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      }

  // ---- Problem Statement tab ----
  Widget _problemTab(DocumentSnapshot data) {
    final title = data.safeGet('problemStatementTitle',
        data.safeGet('problemStatement', 'Not Assigned'));
    final desc = data.safeGet('problemStatement', 'Not Assigned');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
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
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment,
                        color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Your Problem Statement',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Title',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Description',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(desc,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.6)),
              ),
              const SizedBox(height: 20),
              const Text('Judging Criteria',
                  style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _criteriaRow(Icons.looks_one, 'Round 1: Prelims (50 Marks) — Understanding, User ID, Ideology, Feasibility & Q/A', AppColors.info),
              _criteriaRow(Icons.looks_two, 'Round 2: Mains (50 Marks) — Prototype, Architecture, Constraints, UX, Security', AppColors.warning),
              _criteriaRow(Icons.emoji_events, 'Round 3: Finale (100 Marks) — Impact, Tech Depth, Scalability, Business & Crisis', AppColors.success),
            ],
          ),
        ),
      ),
    );
  }

  Widget _criteriaRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  // ---- Rounds tab ----
  Widget _roundsTab(DocumentSnapshot data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _liveRoundStatusCard(data),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Round Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _roundDetail(
                    'Round 1 - Ideation',
                    'Present your problem understanding and proposed solution approach.',
                    AppColors.info,
                  ),
                  const SizedBox(height: 10),
                  _roundDetail(
                    'Round 2 - Development',
                    'Show your prototype and technical implementation progress.',
                    AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  _roundDetail(
                    'Round 3 - Final Presentation',
                    'Demonstrate the complete working solution with impact analysis.',
                    AppColors.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundDetail(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  // ---- Team tab ----
  Widget _teamTab(DocumentSnapshot data) {
    final members = List.from(data.safeGet('members', []));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.groups, color: AppColors.accentGold),
                  SizedBox(width: 8),
                  Text('Team Members',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: AppColors.textSecondary),
              _memberTile(
                data.safeGet('leaderName', ''),
                data.safeGet('leaderEmail', ''),
                data.safeGet('leaderPhone', ''),
                isLeader: true,
              ),
              if (members.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('No other members added',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...members.map((m) => _memberTile(
                      m['name'] ?? '',
                      m['email'] ?? '',
                      m['phone'] ?? '',
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberTile(String name, String email, String phone,
      {bool isLeader = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLeader
            ? AppColors.accentGold.withOpacity(0.1)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeader
              ? AppColors.accentGold
              : AppColors.primaryRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                isLeader ? AppColors.accentGold : AppColors.primaryRed,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
              style: TextStyle(
                color: isLeader ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('LEADER',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                Text(phone,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN DASHBOARD
// ============================================================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  String searchQuery = '';

  final tabs = [
    {'icon': Icons.dashboard, 'label': 'Overview'},
    {'icon': Icons.groups, 'label': 'Teams'},
    {'icon': Icons.check_circle, 'label': 'Attendance'},
    {'icon': Icons.play_circle, 'label': 'Rounds'},
    {'icon': Icons.leaderboard, 'label': 'Leaderboard'},
  ];

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text('Admin Console',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: _buildContent(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.primaryRed.withOpacity(0.3)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => setState(() => selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accentGold,
          unselectedItemColor: AppColors.textSecondary,
          items: tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t['icon'] as IconData),
                    label: t['label'] as String,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _overviewTab();
      case 1:
        return _teamsTab();
      case 2:
        return _attendanceTab();
      case 3:
        return _roundControlTab();
      case 4:
        return _leaderboardTab();
      default:
        return _overviewTab();
    }
  }

  Widget _overviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const RocketLoader();
        }
        final teams = snapshot.data!.docs;
        final total = teams.length;
        final present =
            teams.where((t) => t.safeGet('isPresent', false) == true).length;
        final allocated = teams
            .where((t) =>
                t.safeGet('roomNumber', 'Not Assigned') != 'Not Assigned')
            .length;
        int totalMembers = 0;
        for (var t in teams) {
          totalMembers += 1;
          totalMembers += (t.safeGet('members', []) as List).length;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overview',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text('Real-time hackathon statistics',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _statBox('Total Teams', total.toString(), Icons.groups,
                      AppColors.primaryRed),
                  _statBox('Participants', totalMembers.toString(),
                      Icons.people, AppColors.info),
                  _statBox('Present', '$present/$total',
                      Icons.check_circle, AppColors.success),
                  _statBox('Allocated', '$allocated/$total', Icons.room,
                      AppColors.warning),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Registrations',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (teams.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No teams yet',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        )
                      else
                        ...teams.take(5).map((team) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primaryRed,
                                    child: Text(
                                      (team.safeGet('teamName', 'T')
                                              as String)
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            team.safeGet(
                                                'teamName', 'Unknown'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        Text(
                                            team.safeGet(
                                                'leaderName', 'Unknown'),
                                            style: const TextStyle(
                                                color: AppColors
                                                    .textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: team.safeGet(
                                                  'isPresent', false)
                                          ? AppColors.success
                                              .withOpacity(0.2)
                                          : AppColors.warning
                                              .withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      team.safeGet('isPresent', false)
                                          ? 'Present'
                                          : 'Pending',
                                      style: TextStyle(
                                        color: team.safeGet(
                                                'isPresent', false)
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search team or leader...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.accentGold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _downloadTeamsCsv,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Excel', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ],
          ),
),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('teams').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const RocketLoader();
              }
              var teams = snapshot.data!.docs.where((t) {
                if (searchQuery.isEmpty) return true;
                return (t.safeGet('teamName', '') as String)
                        .toLowerCase()
                        .contains(searchQuery) ||
                    (t.safeGet('leaderName', '') as String)
                        .toLowerCase()
                        .contains(searchQuery);
              }).toList();

              if (teams.isEmpty) {
                return const Center(
                  child: Text('No teams found',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: teams.length,
                itemBuilder: (context, i) {
                  final team = teams[i];
                  final isPresent = team.safeGet('isPresent', false);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryRed,
                                child: Text(
                                  (team.safeGet('teamName', 'T') as String)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        team.safeGet(
                                            'teamName', 'Unknown Team'),
                                        style: const TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'Leader: ${team.safeGet('leaderName', 'Unknown')}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPresent
                                      ? AppColors.success.withOpacity(0.2)
                                      : AppColors.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isPresent ? 'Present' : 'Absent',
                                  style: TextStyle(
                                    color: isPresent
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.textSecondary),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _chip(
                                  Icons.room,
                                  team.safeGet(
                                      'roomNumber', 'Not Assigned')),
                              _chip(
                                  Icons.chair,
                                  team.safeGet(
                                      'seatNumber', 'Not Assigned')),
                              _chip(
                                  Icons.assignment,
                                  team.safeGet(
                                      'problemStatementTitle', 'No PS')),
                            ],
                          ),
                          const SizedBox(height: 10),
                  Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => EditTeamDialog(team: team),
                                    ),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _confirmDelete(team),
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.error.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showTeamDetails(team),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('See Team Detail', style: TextStyle(fontSize: 13)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentGold,
                                  side: const BorderSide(color: AppColors.accentGold),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.accentGold),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

      Future<void> _downloadTeamsCsv() async {
        try {
          final snap = await FirebaseFirestore.instance.collection('teams').get();
          final buffer = StringBuffer();

          // Header row
          buffer.writeln(
              'Team Name,Name,Role,College,Department,Year,Room,Seat,Email,Phone,Total Marks');

          for (final doc in snap.docs) {
            final teamName = doc.safeGet('teamName', '');
            final college = doc.safeGet('college', '');
            final department = doc.safeGet('department', '');
            final year = doc.safeGet('year', '');
            final room = doc.safeGet('roomNumber', 'Not Assigned');
            final seat = doc.safeGet('seatNumber', 'Not Assigned');

            // Total marks
            double totalMarks = 0;
            final scores = Map<String, dynamic>.from(doc.safeGet('scores', {}));
            scores.forEach((_, v) {
              totalMarks += (v['total'] ?? 0).toDouble();
            });

            // Leader row
            buffer.writeln(
              '"$teamName","${doc.safeGet('leaderName', '')}","Leader","$college","$department","$year","$room","$seat","${doc.safeGet('leaderEmail', '')}","${doc.safeGet('leaderPhone', '')}","${totalMarks.toStringAsFixed(0)}"',
            );

            // Member rows
            final members = List.from(doc.safeGet('members', []));
            for (final m in members) {
              buffer.writeln(
                '"$teamName","${m['name'] ?? ''}","Member","$college","$department","$year","$room","$seat","${m['email'] ?? ''}","${m['phone'] ?? ''}","${totalMarks.toStringAsFixed(0)}"',
              );
            }
          }

          final csvData = buffer.toString();

          if (kIsWeb) {
            // Cross-platform Web download (opens/downloads CSV in browser)
            final encodedUri =
                'data:text/csv;charset=utf-8,' + Uri.encodeComponent(csvData);
            js.globalContext.callMethod('open'.toJS, encodedUri.toJS, '_blank'.toJS);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('CSV file generated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Download error: $e'),
                  backgroundColor: AppColors.error),
            );
          }
        }
      }

  void _showTeamDetails(DocumentSnapshot team) {
  final members = List.from(team.safeGet('members', []));

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cardDark,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  team.safeGet('teamName', 'Unknown Team'),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Leader Section
                const Text('Leader Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _detailRow(Icons.person, 'Name', team.safeGet('leaderName', '')),
                _detailRow(Icons.email, 'Email', team.safeGet('leaderEmail', '')),
                _detailRow(Icons.phone, 'Phone', team.safeGet('leaderPhone', '')),
                _detailRow(Icons.school, 'College', team.safeGet('college', 'N/A')),
                _detailRow(Icons.business, 'Department', team.safeGet('department', 'N/A')),
                _detailRow(Icons.calendar_today, 'Year', team.safeGet('year', 'N/A')),

                const SizedBox(height: 20),
                const Text('Team Members',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                if (members.isEmpty)
                  const Text('No additional members',
                      style: TextStyle(color: AppColors.textSecondary))
                else
                  ...members.asMap().entries.map((e) {
                    final m = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryRed.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member ${e.key + 1}: ${m['name'] ?? ''}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Email: ${m['email'] ?? ''}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                          Text('Phone: ${m['phone'] ?? ''}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),
                // Allocation info
                const Text('Allocation',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _detailRow(Icons.room, 'Room', team.safeGet('roomNumber', 'Not Assigned')),
                _detailRow(Icons.chair, 'Seat', team.safeGet('seatNumber', 'Not Assigned')),
                _detailRow(Icons.assignment, 'Problem',
                    team.safeGet('problemStatementTitle',
                        team.safeGet('problemStatement', 'Not Assigned'))),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _detailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentGold),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    ),
  );
}

  void _confirmDelete(DocumentSnapshot team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title:
            const Text('Delete Team?', style: TextStyle(color: Colors.white)),
        content: Text(
            'Are you sure you want to delete "${team.safeGet('teamName', 'this team')}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team.id)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _attendanceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const RocketLoader();
        }
        final teams = snapshot.data!.docs;
        final present =
            teams.where((t) => t.safeGet('isPresent', false) == true).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attendance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text('Tap a team card to toggle attendance',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Column(
                        children: [
                          Text('$present',
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text('Present',
                              style: TextStyle(
                                  color: AppColors.success, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Column(
                        children: [
                          Text('${teams.length - present}',
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text('Absent',
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.info),
                      ),
                      child: Column(
                        children: [
                          Text(
                              teams.isEmpty
                                  ? '0%'
                                  : '${(present * 100 / teams.length).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: AppColors.info,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text('Rate',
                              style: TextStyle(
                                  color: AppColors.info, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teams.length,
                itemBuilder: (context, i) {
                  final team = teams[i];
                  final isPresent = team.safeGet('isPresent', false);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('teams')
                            .doc(team.id)
                            .update({'isPresent': !isPresent});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPresent
                                ? AppColors.success
                                : AppColors.error,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPresent ? Icons.check : Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      team.safeGet('teamName', 'Unknown'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'Leader: ${team.safeGet('leaderName', 'Unknown')}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              isPresent ? 'PRESENT' : 'ABSENT',
                              style: TextStyle(
                                color: isPresent
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _roundControlTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('settings')
          .doc('global')
          .snapshots(),
      builder: (context, snap) {
        Map<String, dynamic> settings = {};
        if (snap.hasData && snap.data!.exists) {
          settings = snap.data!.data() as Map<String, dynamic>;
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Round Control',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text('Manage hackathon round progression',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Changes here update all participants in real-time',
                        style:
                            TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _roundControlCard('Round 1', 'Ideation & Prototype',
                  settings['round1Status'] ?? 'pending', 'round1Status'),
              const SizedBox(height: 12),
              _roundControlCard('Round 2', 'Development Phase',
                  settings['round2Status'] ?? 'pending', 'round2Status'),
              const SizedBox(height: 12),
              _roundControlCard('Round 3', 'Final Presentation',
                  settings['round3Status'] ?? 'pending', 'round3Status'),
            ],
          ),
        );
      },
    );
  }

  Widget _roundControlCard(
      String round, String subtitle, String status, String dbKey) {
    Color statusColor;
    if (status == 'started') {
      statusColor = AppColors.success;
    } else if (status == 'ended') {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.textSecondary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag, color: AppColors.primaryRed),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(round,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statusBtn('Pending', 'pending', status, dbKey,
                      AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statusBtn('Start', 'started', status, dbKey,
                      AppColors.success),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statusBtn(
                      'End', 'ended', status, dbKey, AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(String label, String value, String current, String key,
      Color color) {
    final isActive = current == value;
    return ElevatedButton(
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('global')
            .set({key: value}, SetOptions(merge: true));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : AppColors.surfaceDark,
        foregroundColor: isActive ? Colors.white : color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _leaderboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const RocketLoader();
        }

        var teams = snapshot.data!.docs.map((doc) {
          double total = 0;
          Map<String, dynamic> scores =
              Map<String, dynamic>.from(doc.safeGet('scores', {}));
          scores.forEach((key, value) {
            total += (value['total'] ?? 0).toDouble();
          });
          return {'doc': doc, 'total': total};
        }).toList();

        teams.sort((a, b) =>
            (b['total'] as double).compareTo(a['total'] as double));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live Leaderboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text('Rankings based on total marks by reviewers',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SizedBox(
                                  width: 50,
                                  child: Text('RANK',
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 150,
                                  child: Text('TEAM',
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R1',
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R2',
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R3',
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 80,
                                  child: Text('TOTAL',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(color: AppColors.textSecondary),
                          ...teams.asMap().entries.map((entry) {
                            int rank = entry.key + 1;
                            var team = entry.value['doc'] as DocumentSnapshot;
                            double total = entry.value['total'] as double;
                            Map<String, dynamic> scores =
                                Map<String, dynamic>.from(
                                    team.safeGet('scores', {}));

                            String getScoreStr(String round) {
                              if (scores[round] != null) {
                                int maxM = (round == 'Round 3') ? 100 : 50;
                                return '${(scores[round]['total'] ?? 0).toStringAsFixed(0)}/$maxM';
                              }
                              return 'Pend';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: _rankBadge(rank),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            team.safeGet('teamName', 'Unknown'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                            team.safeGet('leaderName', '...'),
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 1'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 1') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 2'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 2') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 3'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 3') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      '${total.toStringAsFixed(0)}/200',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: AppColors.accentGold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rankBadge(int rank) {
    Color color;
    if (rank == 1) {
      color = AppColors.accentGold;
    } else if (rank == 2) {
      color = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      color = const Color(0xFFCD7F32);
    } else {
      color = AppColors.textSecondary;
    }

    return Text('#$rank',
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 14));
  }
}

// ============================================================
// REVIEWER DASHBOARD
// ============================================================
class ReviewerDashboard extends StatefulWidget {
  const ReviewerDashboard({super.key});

  @override
  State<ReviewerDashboard> createState() => _ReviewerDashboardState();
}

class _ReviewerDashboardState extends State<ReviewerDashboard> {
  int selectedIndex = 0;
  String searchQuery = '';

  final tabs = [
  {'icon': Icons.rate_review, 'label': 'Grade'},
  {'icon': Icons.pending_actions, 'label': 'Pending'},
  {'icon': Icons.task_alt, 'label': 'Completed'},
  {'icon': Icons.leaderboard, 'label': 'Board'},
];

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rate_review, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text('Reviewer Panel',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: [
  _evaluateTab(),
  _statusTab(showPending: true),
  _statusTab(showPending: false),
  _leaderboardTab(),
][selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.primaryRed.withOpacity(0.3)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => setState(() => selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.info,
          unselectedItemColor: AppColors.textSecondary,
          items: tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t['icon'] as IconData),
                    label: t['label'] as String,
                  ))
              .toList(),
        ),
      ),
    );
  }
  Widget _statusTab({required bool showPending}) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('teams').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const RocketLoader();

      final teams = snapshot.data!.docs.where((t) {
        final scores = Map<String, dynamic>.from(t.safeGet('scores', {}));
        final pending = ['Round 1', 'Round 2', 'Round 3']
            .where((r) => scores[r] == null)
            .toList();
        return showPending ? pending.isNotEmpty : pending.length < 3;
      }).toList();

      int pendingCount = 0;
      int doneCount = 0;
      for (final t in snapshot.data!.docs) {
        final scores = Map<String, dynamic>.from(t.safeGet('scores', {}));
        for (final r in ['Round 1', 'Round 2', 'Round 3']) {
          if (scores[r] == null) {
            pendingCount++;
          } else {
            doneCount++;
          }
        }
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    showPending ? 'Pending Reviews' : 'Completed Reviews',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (showPending ? AppColors.warning : AppColors.success)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: showPending
                            ? AppColors.warning
                            : AppColors.success),
                  ),
                  child: Text(
                    showPending ? '$pendingCount pending' : '$doneCount done',
                    style: TextStyle(
                      color: showPending
                          ? AppColors.warning
                          : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: teams.isEmpty
                ? Center(
                    child: Text(
                      showPending
                          ? 'No pending reviews'
                          : 'No completed reviews yet',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: teams.length,
                    itemBuilder: (context, i) {
                      final team = teams[i];
                      final scores = Map<String, dynamic>.from(
                          team.safeGet('scores', {}));
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.safeGet('teamName', 'Unknown'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Room: ${team.safeGet('roomNumber', 'Not Assigned')}  •  ${team.safeGet('leaderName', '')}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              ...['Round 1', 'Round 2', 'Round 3'].map((round) {
                                final done = scores[round] != null;
                                if (showPending && done) {
                                  return const SizedBox.shrink();
                                }
                                if (!showPending && !done) {
                                  return const SizedBox.shrink();
                                }
                                final marks = done
                                    ? '${(scores[round]['total'] ?? 0).toString()}/40'
                                    : '—';
                                final color = done
                                    ? AppColors.success
                                    : AppColors.warning;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: color.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        done
                                            ? Icons.check_circle
                                            : Icons.hourglass_bottom,
                                        color: color,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          done ? '$round completed' : '$round pending',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        marks,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}

  Widget _evaluateTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search team to evaluate...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.info),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('teams').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const RocketLoader();
              }
              var teams = snapshot.data!.docs.where((t) {
                if (searchQuery.isEmpty) return true;
                return (t.safeGet('teamName', '') as String)
                        .toLowerCase()
                        .contains(searchQuery) ||
                    (t.safeGet('problemStatementTitle', '') as String)
                        .toLowerCase()
                        .contains(searchQuery);
              }).toList();

              if (teams.isEmpty) {
                return const Center(
                  child: Text('No teams found',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: teams.length,
                itemBuilder: (context, i) {
                  final team = teams[i];
                  Map<String, dynamic> scores =
                      Map<String, dynamic>.from(team.safeGet('scores', {}));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryRed,
                                child: Text(
                                  (team.safeGet('teamName', 'T') as String)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        team.safeGet(
                                            'teamName', 'Unknown Team'),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'PS: ${team.safeGet('problemStatementTitle', 'Not Assigned')}',
                                        style: const TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _reviewBtn('R1', team, 'Round 1',
                                  scores['Round 1'] != null, AppColors.info),
                              _reviewBtn(
                                  'R2',
                                  team,
                                  'Round 2',
                                  scores['Round 2'] != null,
                                  AppColors.warning),
                              _reviewBtn(
                                  'R3',
                                  team,
                                  'Round 3',
                                  scores['Round 3'] != null,
                                  AppColors.success),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _reviewBtn(String label, DocumentSnapshot team, String roundName,
      bool isDone, Color color) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => ReviewDialog(team: team, roundName: roundName),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDone ? color : AppColors.surfaceDark,
        foregroundColor: isDone ? Colors.white : color,
        side: BorderSide(color: color, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDone ? Icons.check_circle : Icons.edit, size: 16),
          const SizedBox(width: 4),
          Text(isDone ? '$label Graded' : 'Grade $label',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _leaderboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const RocketLoader();

        var teams = snapshot.data!.docs.map((doc) {
          double total = 0;
          Map<String, dynamic> scores =
              Map<String, dynamic>.from(doc.safeGet('scores', {}));
          scores.forEach((key, value) {
            total += (value['total'] ?? 0).toDouble();
          });
          return {'doc': doc, 'total': total};
        }).toList();

        teams.sort((a, b) =>
            (b['total'] as double).compareTo(a['total'] as double));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reviewer Leaderboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text('See detailed marks of all teams',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SizedBox(
                                  width: 50,
                                  child: Text('RANK',
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 150,
                                  child: Text('TEAM',
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R1',
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R2',
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Text('R3',
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 80,
                                  child: Text('TOTAL',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const Divider(color: AppColors.textSecondary),
                          ...teams.asMap().entries.map((entry) {
                            int rank = entry.key + 1;
                            var team = entry.value['doc'] as DocumentSnapshot;
                            double total = entry.value['total'] as double;
                            Map<String, dynamic> scores =
                                Map<String, dynamic>.from(
                                    team.safeGet('scores', {}));

                            String getScoreStr(String round) {
                              if (scores[round] != null) {
                                int maxM = (round == 'Round 3') ? 100 : 50;
                                return '${(scores[round]['total'] ?? 0).toStringAsFixed(0)}/$maxM';
                              }
                              return 'Pend';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 50,
                                      child: Text('#$rank',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            team.safeGet('teamName', 'Unknown'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 1'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 1') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 2'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 2') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                      width: 60,
                                      child: Text(getScoreStr('Round 3'),
                                          style: TextStyle(
                                              color: getScoreStr('Round 3') ==
                                                      'Pend'
                                                  ? AppColors.textSecondary
                                                  : Colors.white))),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      '${total.toStringAsFixed(0)}/200',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: AppColors.info,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// EDIT TEAM DIALOG (Accepts dynamic team)
// ============================================================
class EditTeamDialog extends StatefulWidget {
  final dynamic team; // Accept dynamic to prevent type mismatch
  const EditTeamDialog({super.key, required this.team});

  @override
  State<EditTeamDialog> createState() => _EditTeamDialogState();
}

class _EditTeamDialogState extends State<EditTeamDialog> {
  late TextEditingController teamNameCtrl;
  late TextEditingController leaderNameCtrl;
  late TextEditingController leaderPhoneCtrl;
  late TextEditingController roomCtrl;
  late TextEditingController seatCtrl;
  late TextEditingController problemCtrl;
  late TextEditingController problemTitleCtrl;
  late bool r1Completed;
  late bool r2Completed;
  late bool r3Completed;

  @override
  void initState() {
    super.initState();
    final t = widget.team as DocumentSnapshot;
    teamNameCtrl = TextEditingController(text: t.safeGet('teamName', ''));
    leaderNameCtrl = TextEditingController(text: t.safeGet('leaderName', ''));
    leaderPhoneCtrl = TextEditingController(text: t.safeGet('leaderPhone', ''));
    roomCtrl = TextEditingController(text: t.safeGet('roomNumber', ''));
    seatCtrl = TextEditingController(text: t.safeGet('seatNumber', ''));
    problemCtrl =
        TextEditingController(text: t.safeGet('problemStatement', ''));
    problemTitleCtrl =
        TextEditingController(text: t.safeGet('problemStatementTitle', ''));
    r1Completed = t.safeGet('round1Completed', false);
    r2Completed = t.safeGet('round2Completed', false);
    r3Completed = t.safeGet('round3Completed', false);
  }

  Future<void> save() async {
    final t = widget.team as DocumentSnapshot;
    await FirebaseFirestore.instance.collection('teams').doc(t.id).update({
      'teamName': teamNameCtrl.text.trim(),
      'leaderName': leaderNameCtrl.text.trim(),
      'leaderPhone': leaderPhoneCtrl.text.trim(),
      'roomNumber': roomCtrl.text.trim(),
      'seatNumber': seatCtrl.text.trim(),
      'problemStatement': problemCtrl.text.trim(),
      'problemStatementTitle': problemTitleCtrl.text.trim(),
      'round1Completed': r1Completed,
      'round2Completed': r2Completed,
      'round3Completed': r3Completed,
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _tf(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardDark,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: AppColors.accentGold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Edit Team',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: AppColors.textSecondary),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tf(teamNameCtrl, 'Team Name'),
                    _tf(leaderNameCtrl, 'Leader Name'),
                    _tf(leaderPhoneCtrl, 'Leader Phone'),
                    const SizedBox(height: 8),
                    const Text('Allocation',
                        style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _tf(roomCtrl, 'Room Number'),
                    _tf(seatCtrl, 'Seat Number'),
                    _tf(problemTitleCtrl, 'Problem Statement Title'),
                    _tf(problemCtrl, 'Problem Statement Description',
                        maxLines: 4),
                    const SizedBox(height: 8),
                    const Text('Round Completion',
                        style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Round 1 Completed',
                          style: TextStyle(color: Colors.white)),
                      value: r1Completed,
                      activeColor: AppColors.success,
                      onChanged: (v) => setState(() => r1Completed = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Round 2 Completed',
                          style: TextStyle(color: Colors.white)),
                      value: r2Completed,
                      activeColor: AppColors.success,
                      onChanged: (v) => setState(() => r2Completed = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Round 3 Completed',
                          style: TextStyle(color: Colors.white)),
                      value: r3Completed,
                      activeColor: AppColors.success,
                      onChanged: (v) => setState(() => r3Completed = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.textSecondary),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REVIEW DIALOG
// ============================================================
// ============================================================
// OFFICIAL WONDERS OF AI RUBRIC REVIEW DIALOG
// ============================================================
class ReviewDialog extends StatefulWidget {
  final dynamic team;
  final String roundName;

  const ReviewDialog({super.key, required this.team, required this.roundName});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late Map<String, dynamic> rubric;
  late List<double> scoresList;
  final feedbackCtrl = TextEditingController();
  bool isSubmitting = false;

  final Map<String, Map<String, dynamic>> rubricsConfig = {
    'Round 1': {
      'title': 'Round 1 — Prelims (50 Marks)',
      'maxTotal': 50,
      'maxPerSlider': 10.0,
      'criteria': [
        'Problem Understanding & Clarity',
        'Target User Identification',
        'Ideology / Insight',
        'Uniqueness & Feasibility',
        'Technical Reasoning + Comm & Q/A',
      ],
    },
    'Round 2': {
      'title': 'Round 2 — Mains (50 Marks)',
      'maxTotal': 50,
      'maxPerSlider': 10.0,
      'criteria': [
        'Functional Prototype',
        'Technical Architecture',
        'Constraint Compliance',
        'Innovation & UX',
        'Performance + Security & Privacy',
      ],
    },
    'Round 3': {
      'title': 'Round 3 — Grand Finale (100 Marks)',
      'maxTotal': 100,
      'maxPerSlider': 20.0,
      'criteria': [
        'Real-World Impact',
        'Technical Depth',
        'Innovation / Differentiation',
        'Scalability + Robustness Under Failure',
        'Business Feasibility + Crisis Response',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    rubric = rubricsConfig[widget.roundName] ?? rubricsConfig['Round 1']!;
    scoresList = List.filled(rubric['criteria'].length, 0.0);

    final t = widget.team as DocumentSnapshot;
    var scores = Map<String, dynamic>.from(t.safeGet('scores', {}));

    if (scores[widget.roundName] != null) {
      var s = scores[widget.roundName];
      List rawList = s['breakdown'] ?? [];
      for (int i = 0; i < rubric['criteria'].length; i++) {
        if (i < rawList.length) {
          scoresList[i] = (rawList[i] ?? 0).toDouble();
        }
      }
      feedbackCtrl.text = s['feedback'] ?? '';
    }
  }

  Future<void> submitReview() async {
    setState(() => isSubmitting = true);
    final t = widget.team as DocumentSnapshot;
    final user = FirebaseAuth.instance.currentUser;
    var scores = Map<String, dynamic>.from(t.safeGet('scores', {}));

    double total = scoresList.reduce((a, b) => a + b);

    scores[widget.roundName] = {
      'reviewer': user?.email ?? 'Reviewer',
      'breakdown': scoresList,
      'total': total,
      'maxTotal': rubric['maxTotal'],
      'feedback': feedbackCtrl.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    String roundKey = '';
    if (widget.roundName == 'Round 1') roundKey = 'round1Completed';
    if (widget.roundName == 'Round 2') roundKey = 'round2Completed';
    if (widget.roundName == 'Round 3') roundKey = 'round3Completed';

    await FirebaseFirestore.instance.collection('teams').doc(t.id).update({
      'scores': scores,
      if (roundKey.isNotEmpty) roundKey: true,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.roundName} marks saved ($total / ${rubric['maxTotal']})!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.team as DocumentSnapshot;
    double total = scoresList.reduce((a, b) => a + b);
    List<String> criteriaNames = List<String>.from(rubric['criteria']);
    double maxPerSlider = rubric['maxPerSlider'];
    int maxTotal = rubric['maxTotal'];

    return Dialog(
      backgroundColor: AppColors.cardDark,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 800),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.safeGet('teamName', 'Unknown'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(rubric['title'],
                          style: const TextStyle(
                              color: AppColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: AppColors.textSecondary),
            Expanded(
              child: isSubmitting
                  ? const RocketLoader(text: 'Saving Marks...')
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(criteriaNames.length, (index) {
                            return _slider(
                              criteriaNames[index],
                              scoresList[index],
                              maxPerSlider,
                              (v) => setState(() => scoresList[index] = v),
                            );
                          }),
                          const SizedBox(height: 12),
                          TextField(
                            controller: feedbackCtrl,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Reviewer Comments (Optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!isSubmitting) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Round Score',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${total.toInt()} / $maxTotal',
                        style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.textSecondary),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Marks'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double val, double maxVal, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
              Text('${val.toInt()} / ${maxVal.toInt()}',
                  style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              activeTrackColor: AppColors.info,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppColors.accentGold,
            ),
            child: Slider(
              value: val,
              min: 0,
              max: maxVal,
              divisions: maxVal.toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
