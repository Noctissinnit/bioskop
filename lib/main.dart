import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = true;

  void _toggleAuthScreen() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Bioskop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF78909C)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            // User is logged in, determine screen by role
            return RoleRoutingWrapper(user: snapshot.data!);
          } else {
            // User is not logged in
            if (_isLogin) {
              return LoginScreen(
                onNavigateToSignUp: _toggleAuthScreen,
              );
            } else {
              return SignUpScreen(
                onNavigateToLogin: _toggleAuthScreen,
              );
            }
          }
        },
      ),
    );
  }
}

class RoleRoutingWrapper extends StatefulWidget {
  final User user;
  const RoleRoutingWrapper({super.key, required this.user});

  @override
  State<RoleRoutingWrapper> createState() => _RoleRoutingWrapperState();
}

class _RoleRoutingWrapperState extends State<RoleRoutingWrapper> {
  final _authService = AuthService();
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  void _checkRole() async {
    try {
      String? role = await _authService.getUserRole(widget.user.uid);
      if (role == null && widget.user.email != null && widget.user.email!.trim().toLowerCase().startsWith('admin')) {
        role = 'admin';
        await _authService.setUserRole(widget.user.uid, 'admin');
      }
      if (mounted) {
        setState(() {
          _role = role;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _role = null;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_role == 'admin') {
      return const AdminScreen();
    } else {
      return const HomeScreen();
    }
  }
}
