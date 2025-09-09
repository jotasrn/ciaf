// lib/core/utils/string_extensions.dart

extension StringExtensions on String {
  /// Converte a primeira letra da String para maiúscula.
  /// Ex: 'segunda'.capitalize() => 'Segunda'
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}