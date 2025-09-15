import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/aluno_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/category_selection_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/chamadas_do_dia.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/kpi_card.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/simple_form_dialog.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A tela agora cria todos os Cubits que ela precisa
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            RepositoryProvider.of<DashboardRepository>(context),
          )..fetchSummary(),
        ),
        BlocProvider(
          create: (context) => SportCubit(
            RepositoryProvider.of<SportRepository>(context),
          )..fetchSports(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return _buildMobileLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KpiSection(),
          SizedBox(height: 24),
          _EsportesSection(),
          SizedBox(height: 24),
          _ChamadasSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KpiSection(),
                  SizedBox(height: 24),
                  _EsportesSection(),
                ],
              ),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ChamadasSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  const _KpiSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardSuccess) {
          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              KpiCard(
                title: 'Total de Alunos',
                value: state.totalAlunos.toString(),
                icon: Icons.group,
                color: Colors.blue,
                onTap: () {
                  // Navega para a nova tela de alunos
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AlunoListScreen(),
                  ));
                },
              ),
              KpiCard(
                title: 'Turmas',
                value: state.totalTurmas.toString(),
                icon: Icons.sports_soccer,
                color: Colors.orange,
                onTap: () => context.read<NavigationCubit>().selectPage(3),
              ),
              KpiCard(
                title: 'Não Pagantes',
                value: state.totalNaoPagantes.toString(),
                icon: Icons.money_off,
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AlunoListScreen(
                      initialFilters: {'status_pagamento': 'pendente'},
                    ),
                  ));
                },
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _ChamadasSection extends StatelessWidget {
  const _ChamadasSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: ChamadasDoDiaWidget(),
    );
  }
}

class _EsportesSection extends StatelessWidget {
  const _EsportesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Navegar por Esportes',
                style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: Icon(Icons.add_circle,
                  color: Theme.of(context).primaryColor),
              onPressed: () async {
                final novoEsporte = await showSimpleFormDialog(
                    context: context, title: 'Adicionar Novo Esporte');
                if (novoEsporte != null && novoEsporte.isNotEmpty) {
                  context.read<SportCubit>().createSport(nome: novoEsporte);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<SportCubit, SportState>(
          builder: (context, state) {
            if (state is SportLoadSuccess) {
              return Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: state.sports
                    .map((sport) => _buildSportCard(context, sport))
                    .toList(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
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
      width: 130,
      height: 130,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategorySelectionScreen(
                  esporteId: sport.id, esporteNome: sport.nome),
            ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: Theme.of(context).primaryColor, size: 40),
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

