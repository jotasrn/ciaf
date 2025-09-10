import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/app/theme.dart';
import 'package:escolinha_futebol_app/app/widgets/custom_text_form_field.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _chaveDoFormulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // Layout para telas largas (Web/Desktop) - SEM ALTERAÇÕES
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildDecorativePanel(),
        ),
        Expanded(
          child: Center(
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  // ======================= LAYOUT MOBILE MODIFICADO =======================
  Widget _buildMobileLayout() {
    // Agora o layout mobile é simplesmente o formulário centralizado
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: _buildLoginForm(isMobile: true), // Passa a flag 'isMobile'
      ),
    );
  }
  // =======================================================================

  Widget _buildDecorativePanel() {
    return Container(
      color: AppTheme.primaryColor,
      child: const Center(
        child: Text(
          'CIAF',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4.0,
          ),
        ),
      ),
    );
  }

  // ======================= FORMULÁRIO MODIFICADO =======================
  Widget _buildLoginForm({bool isMobile = false}) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _chaveDoFormulario,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mostra o logo "CIAF" apenas no layout mobile
                if (isMobile)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'CIAF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                Text(
                  'Acesse sua conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32.0),
                CustomTextFormField(
                  controller: _controladorEmail,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty || !valor.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  controller: _controladorSenha,
                  label: 'Senha',
                  icon: Icons.lock_outline,
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
                        if (_chaveDoFormulario.currentState!.validate()) {
                          context.read<AuthCubit>().login(
                            _controladorEmail.text,
                            _controladorSenha.text,
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
    );
  }
}