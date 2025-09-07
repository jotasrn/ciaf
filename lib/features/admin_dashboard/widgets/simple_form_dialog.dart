import 'package:flutter/material.dart';

Future<String?> showSimpleFormDialog({
  required BuildContext context,
  required String title,
  String? initialValue,
}) {
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController(text: initialValue ?? '');

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) =>
                value!.trim().isEmpty ? 'O nome não pode ser vazio' : null,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('Salvar'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(textController.text);
              }
            },
          ),
        ],
      );
    },
  );
}
