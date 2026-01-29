import 'package:butlrapp_client/butlrapp_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
///
/// Environment-based configuration:
/// - Debug builds use localhost (http://localhost:8080/)
/// - Release builds use production (https://butlr1.api.serverpod.space/)
const bool isProduction = bool.fromEnvironment('dart.vm.product');
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  //
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
  //
  // Otherwise, the server URL is fetched from the assets/config.json file or
  // defaults to http://$localhost:8080/ if not found.
  // final serverUrl = await getServerUrl();
  
  // Environment-based URL selection:
  // - Debug builds use localhost
  // - Release builds use production Serverpod Cloud
  final serverUrl = isProduction 
      ? 'https://butlr1.api.serverpod.space'  // Production
      : 'http://localhost:8085';               // Development

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butlr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF313A64),
          primary: const Color(0xFF313A64),
          secondary: const Color(0xFF7B61FF),
          surface: Colors.white,
          background: const Color(0xFFF5F7FA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF313A64)),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF313A64)),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D3142)),
            bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5A5E72)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: const Color(0xFF313A64),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF313A64), width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
