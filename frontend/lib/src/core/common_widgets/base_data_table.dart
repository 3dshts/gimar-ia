// frontend/lib/src/core/common_widgets/base_data_table.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ============================================
// CONSTANTES COMPARTIDAS
// ============================================

/// Breakpoint para determinar vista móvil.
class DataTableBreakpoints {
  static const double mobile = 600.0;
}

/// Dimensiones de la tabla en desktop.
class DesktopTableDimensions {
  static const double horizontalMargin = 24.0;
  static const double headingRowHeight = 56.0;
  static const double dataRowHeight = 56.0;
}

/// Dimensiones de la tabla en móvil.
class MobileTableDimensions {
  static const double horizontalMargin = 12.0;
  static const double headingRowHeight = 48.0;
  static const double dataRowHeight = 48.0;
  static const double iconSize = 16.0;
  static const double tableMinWidth = 100.0;
}

/// Tamaños de fuente para tablas.
class DataTableFontSizes {
  static const double mobileText = 12.0;
  static const double mobileHint = 10.0;
}

/// Configuración de bordes.
class DataTableBorderConfig {
  static const double radius = 8.0;
}

/// Textos comunes de tablas.
class DataTableTexts {
  static const String swipeHint = 'Desliza horizontalmente para ver más';
}

// ============================================
// CONFIGURACIÓN DE COLUMNA
// ============================================

/// Configuración para una columna de la tabla.
class DataTableColumnConfig {
  const DataTableColumnConfig({
    required this.label,
    required this.maxWidth,
  });

  final String label;
  final double maxWidth;
}

// ============================================
// WIDGET BASE DE TABLA DE DATOS
// ============================================

/// Widget base genérico para tablas de datos con soporte responsive.
/// 
/// Soporta vista desktop (tabla completa) y móvil (tabla scrolleable horizontal).
/// 
/// Tipo genérico [T] representa el modelo de datos de cada fila.
class BaseDataTable<T> extends StatelessWidget {
  const BaseDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.getRowData,
    required this.countLabel,
    this.desktopColumnSpacing = 32.0,
    this.mobileColumnSpacing = 16.0,
  });

  /// Lista de datos a mostrar en la tabla.
  final List<T> data;

  /// Configuración de las columnas (label y ancho máximo para móvil).
  final List<DataTableColumnConfig> columns;

  /// Función que extrae los datos de una fila desde el modelo.
  /// Debe retornar una lista de strings en el mismo orden que [columns].
  final List<String> Function(T) getRowData;

  /// Label para el contador (ej: "Usuarios", "Logs de Actividad").
  final String countLabel;

  /// Espaciado entre columnas en vista desktop.
  final double desktopColumnSpacing;

  /// Espaciado entre columnas en vista móvil.
  final double mobileColumnSpacing;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < DataTableBreakpoints.mobile;

    return isMobile ? _buildMobileView(context) : _buildDesktopView();
  }

  // ============================================
  // VISTA DESKTOP
  // ============================================

  Widget _buildDesktopView() {
    return DataTable(
      columnSpacing: desktopColumnSpacing,
      horizontalMargin: DesktopTableDimensions.horizontalMargin,
      headingRowHeight: DesktopTableDimensions.headingRowHeight,
      dataRowHeight: DesktopTableDimensions.dataRowHeight,
      columns: columns.map((col) => DataColumn(label: Text(col.label))).toList(),
      rows: data.map(_buildDesktopRow).toList(),
    );
  }

  DataRow _buildDesktopRow(T item) {
    final rowData = getRowData(item);
    return DataRow(
      cells: rowData.map((text) => DataCell(Text(text))).toList(),
    );
  }

  // ============================================
  // VISTA MÓVIL
  // ============================================

  Widget _buildMobileView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwipeHint(),
        const SizedBox(height: AppSpacing.medium),
        _buildScrollableTable(context),
        const SizedBox(height: AppSpacing.small),
        _buildCounter(),
      ],
    );
  }

  Widget _buildSwipeHint() {
    return Row(
      children: [
        Icon(
          Icons.swipe,
          size: MobileTableDimensions.iconSize,
          color: AppColors.text.withOpacity(0.6),
        ),
        const SizedBox(width: 4.0),
        Text(
          DataTableTexts.swipeHint,
          style: TextStyle(
            fontSize: DataTableFontSizes.mobileHint,
            color: AppColors.text.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableTable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(DataTableBorderConfig.radius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width -
                MobileTableDimensions.tableMinWidth,
          ),
          child: _buildMobileDataTable(),
        ),
      ),
    );
  }

  Widget _buildMobileDataTable() {
    return DataTable(
      columnSpacing: mobileColumnSpacing,
      horizontalMargin: MobileTableDimensions.horizontalMargin,
      headingRowHeight: MobileTableDimensions.headingRowHeight,
      dataRowHeight: MobileTableDimensions.dataRowHeight,
      headingTextStyle: TextStyle(
        fontWeight: AppFontWeights.semiBold,
        fontSize: DataTableFontSizes.mobileText,
        color: AppColors.primary,
      ),
      dataTextStyle: TextStyle(
        fontSize: DataTableFontSizes.mobileText,
        color: AppColors.text,
      ),
      columns: _buildMobileColumns(),
      rows: data.map(_buildMobileRow).toList(),
    );
  }

  List<DataColumn> _buildMobileColumns() {
    return columns
        .map(
          (col) => DataColumn(
            label: Flexible(
              child: Text(
                col.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        )
        .toList();
  }

  DataRow _buildMobileRow(T item) {
    final rowData = getRowData(item);
    return DataRow(
      cells: List.generate(
        rowData.length,
        (index) => DataCell(
          _buildConstrainedCell(
            rowData[index],
            columns[index].maxWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildConstrainedCell(String text, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildCounter() {
    return Row(
      children: [
        Text(
          '$countLabel (${data.length})',
          style: TextStyle(
            fontSize: DataTableFontSizes.mobileText,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}