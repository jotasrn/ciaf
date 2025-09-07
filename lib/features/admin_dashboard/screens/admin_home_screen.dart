import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/category_selection_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/user_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/chamadas_do_dia.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/kpi_card.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/simple_form_dialog.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Navegar por Esportes',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () async {
                    final novoEsporte = await showSimpleFormDialog(
                      context: context,
                      title: 'Adicionar Novo Esporte',
                    );
                    if (novoEsporte != null) {
                      // TODO: Chamar um SportCubit para criar o esporte
                      print('Novo esporte a ser criado: $novoEsporte');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildSportCard(context, 'Futebol', Icons.sports_soccer,
                    '66d8f28c894236b2f7d81b33'),
                _buildSportCard(context, 'Futsal', Icons.sports,
                    '66d8f28c894236b2f7d81b34'),
                _buildSportCard(context, 'Vôlei', Icons.sports_volleyball,
                    '66d8f28c894236b2f7d81b35'),
                _buildSportCard(
                    context, 'Natação', Icons.pool, '66d8f28c894236b2f7d81b36'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSportCard(
      BuildContext context, String title, IconData icon, String esporteId) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategorySelectionScreen(
                esporteId: esporteId,
                esporteNome: title,
              ),
            ));
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
