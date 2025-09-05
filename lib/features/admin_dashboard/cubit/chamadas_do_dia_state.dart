import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';

// A definição dos estados DEVE estar aqui.
abstract class ChamadasDoDiaState extends Equatable {
  const ChamadasDoDiaState();
  @override
  List<Object> get props => [];
}

class ChamadasDoDiaInitial extends ChamadasDoDiaState {}
class ChamadasDoDiaLoading extends ChamadasDoDiaState {}

class ChamadasDoDiaSuccess extends ChamadasDoDiaState {
  final List<AulaResumoModel> aulas;
  final DateTime selectedDate;

  const ChamadasDoDiaSuccess(this.aulas, this.selectedDate);

  @override
  List<Object> get props => [aulas, selectedDate];
}

class ChamadasDoDiaFailure extends ChamadasDoDiaState {
  final String message;
  const ChamadasDoDiaFailure(this.message);
  @override
  List<Object> get props => [message];
}