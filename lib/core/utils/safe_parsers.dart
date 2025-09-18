import 'package:intl/intl.dart';

// Função para extrair o ID de um campo JSON de forma segura.
String safeGetId(dynamic idField) {
  if (idField is String) {
    return idField;
  }
  if (idField is Map) {
    return idField['\$oid'] ?? '';
  }
  return '';
}

// Função DEFINITIVA para converter datas do MongoDB para DateTime.
DateTime? safeParseDate(dynamic dateField) {
  if (dateField == null) return null;
  if (dateField is Map && dateField.containsKey('\$date')) {
    final dateValue = dateField['\$date'];
    if (dateValue is Map && dateValue.containsKey('\$numberLong')) {
      final millis = int.tryParse(dateValue['\$numberLong']);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
      }
    }
    if (dateValue is String) {
      return DateTime.tryParse(dateValue)?.toLocal();
    }
  }
  if (dateField is String) {
    return DateTime.tryParse(dateField)?.toLocal();
  }
  return null;
}