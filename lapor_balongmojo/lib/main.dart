// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';
import 'package:lapor_balongmojo/screens/perangkat/dashboard_screen_perangkat.dart';
import 'package:lapor_balongmojo/screens/splash_screen.dart';
import 'package:provider/provider.dart';

// --- TAMBAHKAN 2 IMPORT INI ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Dibuat otomatis oleh 'flutterfire configure'

// --- UBAH FUNGSI main MENJADI 'async' ---
void main() async {
  // --- TAMBAHKAN 2 BARIS INI ---
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LaporanProvider>(
          create: (_) => LaporanProvider(),
          update: (ctx, auth, previousLaporan) {
            return LaporanProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Lapor Balongmojo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.status == AuthStatus.uninitialized) {
              return const SplashScreen();
            }
            if (auth.status == AuthStatus.authenticated) {
              if (auth.userRole == 'perangkat') {
                return const DashboardScreenPerangkat();
              }
              return const HomeScreenMasyarakat();
            }
            return const LoginScreen();
          },
        ),
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterMasyarakatScreen.routeName: (ctx) =>
              const RegisterMasyarakatScreen(),
          HomeScreenMasyarakat.routeName: (ctx) => const HomeScreenMasyarakat(),
          DashboardScreenPerangkat.routeName: (ctx) =>
              const DashboardScreenPerangkat(),
        },
      ),
    );
  }
}