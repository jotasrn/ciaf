import 'package:flutter/material.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

class UserFormScreen extends StatefulWidget {
  // Se um usuário for passado, estamos no modo de edição.
  // Se for nulo, estamos no modo de criação.
  final UserModel? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedProfile;
  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.nome ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedProfile = widget.user?.perfil;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Chamar o Cubit para salvar os dados
      print('Formulário Válido!');
      print('Nome: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Senha: ${_passwordController.text}');
      print('Perfil: $_selectedProfile');

      // Volta para a tela anterior após submeter
      if (Navigator.canPop(context)) {
        Navigator.pop(context,
            true); // Envia 'true' para indicar que a lista deve ser atualizada
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuário' : 'Adicionar Novo Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome Completo'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? 'E-mail inválido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: _isEditing ? 'Nova Senha (opcional)' : 'Senha',
                    ),
                    obscureText: true,
                    // A senha só é obrigatória na criação
                    validator: (value) => !_isEditing && value!.isEmpty
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProfile,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    items: ['aluno', 'professor', 'admin']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProfile = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecione um perfil' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                        _isEditing ? 'Salvar Alterações' : 'Criar Usuário'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
