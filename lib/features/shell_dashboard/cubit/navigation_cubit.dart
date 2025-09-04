import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  // O estado inicial é o índice da primeira página (0)
  NavigationCubit() : super(0);

  // Função para mudar de página
  void selectPage(int index) => emit(index);
}