// lib/src/core/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './user_cubit.dart';

/// Este widget es un Provider que inyecta el UserCubit en toda la app.
///
/// Se coloca en la parte superior del árbol de widgets (generalmente en `main.dart`)
/// para que cualquier widget pueda acceder al estado del usuario usando:
///
/// ```dart
/// final userState = context.watch<UserCubit>().state;
/// ```
///
/// o con BlocBuilder/BlocListener si necesitas reaccionar a cambios.

class UserProvider extends StatelessWidget {
  final Widget child;

  const UserProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>(
      create: (_) => UserCubit(),
      child: child,
    );
  }
}
