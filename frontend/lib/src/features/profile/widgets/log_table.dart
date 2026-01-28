// frontend/lib/src/features/profile/widgets/log_table.dart

import 'package:flutter/material.dart';
import '../../../core/models/log.model.dart';
import '../../../core/common_widgets/base_data_table.dart';

// ============================================
// CONSTANTES ESPECÍFICAS DE LOGS
// ============================================

/// Configuración de columnas para la tabla de logs.
class _LogTableColumns {
  static const dateColumn = DataTableColumnConfig(
    label: 'Fecha',
    maxWidth: 100.0,
  );

  static const fullNameColumn = DataTableColumnConfig(
    label: 'Nombre Completo',
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
    dateColumn,
    fullNameColumn,
    usernameColumn,
    emailColumn,
  ];
}

/// Espaciado de columnas para logs.
class _LogTableSpacing {
  static const double desktop = 32.0;
  static const double mobile = 16.0;
}

/// Textos específicos de logs.
class _LogTableTexts {
  static const String countLabel = 'Logs de Actividad';
}

// ============================================
// WIDGET DE TABLA DE LOGS
// ============================================

/// Tabla que muestra los logs de actividad del sistema.
/// 
/// Utiliza [BaseDataTable] para la funcionalidad responsive común.
class LogTable extends StatelessWidget {
  const LogTable({super.key, required this.logs});

  final List<LogModel> logs;

  @override
  Widget build(BuildContext context) {
    return BaseDataTable<LogModel>(
      data: logs,
      columns: _LogTableColumns.all,
      getRowData: _extractLogData,
      countLabel: _LogTableTexts.countLabel,
      desktopColumnSpacing: _LogTableSpacing.desktop,
      mobileColumnSpacing: _LogTableSpacing.mobile,
    );
  }

  /// Extrae los datos de un log como lista de strings.
  List<String> _extractLogData(LogModel log) {
    return [
      log.date,
      log.fullName,
      log.user,
      log.email,
    ];
  }
}