// lib/src/features/fabricacion/providers/calendar_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './calendar_cubit.dart';

/// Provider que inyecta el CalendarCubit en el árbol de widgets.
///
/// Se puede colocar a nivel de la página de Fabricación para que
/// solo esa sección tenga acceso al estado del calendario.
///
/// Uso:
/// ```dart
/// CalendarProvider(
///   child: NotasFabricacionPage(),
/// )
/// ```
class CalendarProvider extends StatelessWidget {
  const CalendarProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalendarCubit>(
      create: (_) => CalendarCubit(),
      child: child,
    );
  }
}