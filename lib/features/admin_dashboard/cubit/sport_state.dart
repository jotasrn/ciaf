import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';

abstract class SportState extends Equatable {
  const SportState();
  @override
  List<Object> get props => [];
}

class SportInitial extends SportState {}
class SportLoading extends SportState {}

class SportLoadSuccess extends SportState {
  final List<SportModel> sports;
  const SportLoadSuccess(this.sports);
  @override
  List<Object> get props => [sports];
}

class SportFailure extends SportState {
  final String message;
  const SportFailure(this.message);
  @override
  List<Object> get props => [message];
}