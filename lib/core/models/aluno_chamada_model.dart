import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/chamada_screen.dart';


enum StatusPresenca { presente, ausente, justificado, pendente }

class AlunoChamadaModel extends Equatable {
  final String id;
  final String nome;
  final StatusPresenca status;

  const AlunoChamadaModel({
    required this.id,
    required this.nome,
    this.status = StatusPresenca.pendente,
  });

  // Cria uma cópia do objeto com um novo status
  AlunoChamadaModel copyWith({StatusPresenca? status}) {
    return AlunoChamadaModel(
      id: id,
      nome: nome,
      status: status ?? this.status,
    );
  }

  factory AlunoChamadaModel.fromJson(Map<String, dynamic> json) {
    StatusPresenca status;
    switch (json['presenca']?['status']) {
      case 'presente':
        status = StatusPresenca.presente;
        break;
      case 'ausente':
        status = StatusPresenca.ausente;
        break;
      case 'justificado':
        status = StatusPresenca.justificado;
        break;
      default:
        status = StatusPresenca.pendente;
    }

    return AlunoChamadaModel(
      id: json['_id']['\$oid'],
      nome: json['nome_completo'],
      status: status,
    );
  }

  @override
  List<Object?> get props => [id, nome, status];
}