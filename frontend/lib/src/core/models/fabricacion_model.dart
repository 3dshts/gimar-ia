// frontend/lib/src/core/models/fabricacion_model.dart

/// Modelo que representa un registro de fabricación del ERP.
class FabricacionModel {
  const FabricacionModel({
    required this.agrupacion,
    required this.nota,
    required this.partida,
    required this.fservicio,
    required this.pedido,
    required this.modelo,
    required this.combinacion,
    required this.titulo,
    required this.pares,
    required this.snoseccion,
    required this.secdescri,
    required this.snoufecha,
  });

  final String agrupacion;      // Agrup
  final String nota;            // Nota
  final String partida;         // Sub
  final DateTime fservicio;     // F. Servicio
  final String pedido;          // Ped. Cliente
  final String modelo;          // Modelo
  final String combinacion;     // Comb
  final String titulo;          // Título
  final String pares;           // Pares
  final String snoseccion;      // Sección
  final String secdescri;       // Descripción
  final DateTime snoufecha;     // F. Sección

  /// Crea una instancia desde JSON.
  factory FabricacionModel.fromJson(Map<String, dynamic> json) {
    return FabricacionModel(
      agrupacion: (json['agrupacion'] as String? ?? '').trim(),
      nota: (json['nota'] as String? ?? '').trim(),
      partida: (json['partida'] as String? ?? '').trim(),
      fservicio: DateTime.parse(json['fservicio'] as String),
      pedido: (json['pedido'] as String? ?? '').trim(),
      modelo: (json['modelo'] as String? ?? '').trim(),
      combinacion: (json['combinacion'] as String? ?? '').trim(),
      titulo: (json['titulo'] as String? ?? '').trim(),
      pares: (json['pares'] as String? ?? '').trim(),
      snoseccion: (json['snoseccion'] as String? ?? '').trim(),
      secdescri: (json['secdescri'] as String? ?? '').trim(),
      snoufecha: DateTime.parse(json['snoufecha'] as String),
    );
  }

  /// Convierte a JSON.
  Map<String, dynamic> toJson() {
    return {
      'agrupacion': agrupacion,
      'nota': nota,
      'partida': partida,
      'fservicio': fservicio.toIso8601String(),
      'pedido': pedido,
      'modelo': modelo,
      'combinacion': combinacion,
      'titulo': titulo,
      'pares': pares,
      'snoseccion': snoseccion,
      'secdescri': secdescri,
      'snoufecha': snoufecha.toIso8601String(),
    };
  }
}