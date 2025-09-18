String safeGetId(dynamic idField) {
  if (idField is String) {
    return idField;
  }
  if (idField is Map) {
    return idField['\$oid'] ?? '';
  }
  return '';
}