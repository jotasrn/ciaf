import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_state.dart';
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
                          title: 'Turmas',
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
            BlocProvider(
              create: (context) => SportCubit(
                RepositoryProvider.of<SportRepository>(context),
              )..fetchSports(),
              child: Builder(builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Navegar por Esportes',
                            style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon:
                          const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () async {
                            final novoEsporte = await showSimpleFormDialog(
                              context: context,
                              title: 'Adicionar Novo Esporte',
                            );
                            if (novoEsporte != null && novoEsporte.isNotEmpty) {
                              context
                                  .read<SportCubit>()
                                  .createSport(nome: novoEsporte);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<SportCubit, SportState>(
                      builder: (context, state) {
                        if (state is SportLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is SportFailure) {
                          return Center(child: Text(state.message));
                        }
                        if (state is SportLoadSuccess) {
                          return Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: state.sports.map((sport) {
                              return _buildSportCard(context, sport);
                            }).toList(),
                          );
                        }
                        return const Text('Nenhum esporte encontrado.');
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportCard(BuildContext context, SportModel sport) {
    IconData iconData = Icons.sports;
    if (sport.nome.toLowerCase().contains('futebol')) {
      iconData = Icons.sports_soccer;
    } else if (sport.nome.toLowerCase().contains('vôlei')) {
      iconData = Icons.sports_volleyball;
    } else if (sport.nome.toLowerCase().contains('natação')) {
      iconData = Icons.pool;
    }

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
                esporteId: sport.id,
                esporteNome: sport.nome,
              ),
            ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Colors.green, size: 40),
              const SizedBox(height: 8),
              Text(
                sport.nome,
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

