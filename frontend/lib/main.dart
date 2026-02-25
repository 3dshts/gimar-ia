// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/src/features/auth/pages/splash_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/user/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  runApp(
    // Inyectamos UserProvider en el nivel raíz
    const UserProvider(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntegrIA - Ahumados Gimar SLU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Agregar soporte de localizaciones
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Idiomas soportados
      supportedLocales: const [
        Locale('es', 'ES'), // Español España
        Locale('es'),       // Español genérico
        Locale('en', 'US'), // Inglés USA
        Locale('en'),       // Inglés genérico
      ],
      // Locale por defecto
      locale: const Locale('es', 'ES'),
      home: const SplashPage(),
    );
  }
}