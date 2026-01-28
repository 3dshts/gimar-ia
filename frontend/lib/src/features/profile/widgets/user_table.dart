// frontend/lib/src/features/profile/widgets/user_table.dart

import 'package:flutter/material.dart';
import '../../../core/models/user.model.dart';
import '../../../core/common_widgets/base_data_table.dart';

// ============================================
// CONSTANTES ESPECÍFICAS DE USUARIOS
// ============================================

/// Configuración de columnas para la tabla de usuarios.
class _UserTableColumns {
  static const nameColumn = DataTableColumnConfig(
    label: 'Nombre',
    maxWidth: 150.0,
  );

  static const usernameColumn = DataTableColumnConfig(
    label: 'Usuario',
    maxWidth: 120.0,
  );

  static const emailColumn = DataTableColumnConfig(
    label: 'Email',
    maxWidth: 200.0,
  );

  static const List<DataTableColumnConfig> all = [
    nameColumn,
    usernameColumn,
    emailColumn,
  ];
}

/// Espaciado de columnas para usuarios.
class _UserTableSpacing {
  static const double desktop = 56.0;
  static const double mobile = 20.0;
}

/// Textos específicos de usuarios.
class _UserTableTexts {
  static const String countLabel = 'Usuarios';
}

// ============================================
// WIDGET DE TABLA DE USUARIOS
// ============================================

/// Tabla que muestra la lista de usuarios del sistema.
/// 
/// Utiliza [BaseDataTable] para la funcionalidad responsive común.
class UserTable extends StatelessWidget {
  const UserTable({super.key, required this.users});

  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return BaseDataTable<UserModel>(
      data: users,
      columns: _UserTableColumns.all,
      getRowData: _extractUserData,
      countLabel: _UserTableTexts.countLabel,
      desktopColumnSpacing: _UserTableSpacing.desktop,
      mobileColumnSpacing: _UserTableSpacing.mobile,
    );
  }

  /// Extrae los datos de un usuario como lista de strings.
  List<String> _extractUserData(UserModel user) {
    return [
      user.fullName,
      user.username,
      user.email,
    ];
  }
}