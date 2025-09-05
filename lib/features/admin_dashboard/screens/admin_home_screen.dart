import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/user_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/chamadas_do_dia.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/kpi_card.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        RepositoryProvider.of<DashboardRepository>(context),
      )..fetchSummary(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardSuccess) {
                  return Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      SizedBox(
                        width: 300,
                        child: KpiCard(
                          title: 'Total de Alunos',
                          value: state.totalAlunos.toString(),
                          icon: Icons.group,
                          color: Colors.blue,
                          onTap: () {
                            // Navega para a tela de usuários com o filtro de perfil
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (context) => UserManagementCubit(
                                  RepositoryProvider.of<UserRepository>(
                                      context),
                                ),
                                child: const UserListScreen(
                                  initialFilters: {'perfil': 'aluno'},
                                ),
                              ),
                            ));
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: KpiCard(
                          title: 'Total de Turmas',
                          value: state.totalTurmas.toString(),
                          icon: Icons.sports_soccer,
                          color: Colors.orange,
                          onTap: () {
                            // Isso fará o NavigationCubit mudar para a página de Turmas (índice 1)
                            context.read<NavigationCubit>().selectPage(1);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: KpiCard(
                          title: 'Não Pagantes',
                          value: state.totalNaoPagantes.toString(),
                          icon: Icons.money_off,
                          color: Colors.red,
                          onTap: () {
                            // Navega para a tela de usuários com o filtro de pagamento
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (context) => UserManagementCubit(
                                  RepositoryProvider.of<UserRepository>(
                                      context),
                                ),
                                child: const UserListScreen(
                                  initialFilters: {
                                    'status_pagamento': 'pendente'
                                  },
                                ),
                              ),
                            ));
                          },
                        ),
                      ),
                    ],
                  );
                }
                if (state is DashboardFailure) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 32),
            // Seção da Lista de Presença
            Text(
              'Chamadas do Dia',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const SizedBox(
              height: 300,
              child: ChamadasDoDiaWidget(),
            ),

            const SizedBox(height: 32),
            // Seção de Navegação por Esportes
            Text(
              'Navegar por Esportes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildSportCard(context, 'Futebol', Icons.sports_soccer),
                _buildSportCard(context, 'Futsal', Icons.sports),
                _buildSportCard(context, 'Vôlei', Icons.sports_volleyball),
                _buildSportCard(context, 'Natação', Icons.pool),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSportCard(BuildContext context, String title, IconData icon) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            print('Clicou em $title');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.green, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

