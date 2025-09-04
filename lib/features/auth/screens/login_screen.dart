import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorSenha = TextEditingController();
  final chaveDoFormulario = GlobalKey<FormState>();

  @override
  void dispose() {
    controladorEmail.dispose();
    controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolinha de Futebol - Login'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          // A navegação agora é controlada pelo BlocBuilder no main.dart
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: chaveDoFormulario,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bem-vindo!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: controladorEmail,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (valor) {
                        if (valor == null || valor.isEmpty || !valor.contains('@')) {
                          return 'Por favor, insira um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: controladorSenha,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Por favor, insira sua senha.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: () {
                            if (chaveDoFormulario.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                controladorEmail.text,
                                controladorSenha.text,
                              );
                            }
                          },
                          child: const Text('Entrar'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}