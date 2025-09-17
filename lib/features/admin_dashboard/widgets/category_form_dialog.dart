import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_cubit.dart';

Future<void> showCategoryFormDialog({required BuildContext context}) async {
  final categoryCubit = context.read<CategoryManagementCubit>();
  await showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: categoryCubit,
      child: const _CategoryFormDialogContent(),
    ),
  );
}

class _CategoryFormDialogContent extends StatefulWidget {
  const _CategoryFormDialogContent();

  @override
  State<_CategoryFormDialogContent> createState() => _CategoryFormDialogContentState();
}

class _CategoryFormDialogContentState extends State<_CategoryFormDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _catNomeController = TextEditingController();
  String? _selectedEsporteId;
  List<SportModel> _esportesDisponiveis = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEsportes();
  }

  Future<void> _loadEsportes() async {
    try {
      final esportes = await context.read<SportRepository>().getSports();
      if (mounted) setState(() => _esportesDisponiveis = esportes);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _catNomeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<CategoryManagementCubit>().createCategoria(
        _catNomeController.text,
        _selectedEsporteId!,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Categoria'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedEsporteId,
                decoration: const InputDecoration(labelText: 'Esporte'),
                items: _esportesDisponiveis.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nome))).toList(),
                onChanged: (id) => setState(() => _selectedEsporteId = id),
                validator: (v) => v == null ? 'Selecione um esporte' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catNomeController,
                decoration: const InputDecoration(labelText: 'Nome da Nova Categoria'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submitForm, child: const Text('Criar')),
      ],
    );
  }
}