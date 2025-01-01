import 'dart:ffi';

class Medicacao {
  // se a dosagem é única, ignora o intervalo
  // portanto, no caso acima, exigir apenas a data de início e horário de início
  String idMedicacao;
  String idUsuario;
  String nome;
  Bool dosagemUnica;
  String intervalo;
  DateTime dataInicio;
  DateTime dataFim;
  DateTime horarioInicio;

  Medicacao({
    required this.idMedicacao,
    required this.idUsuario,
    required this.nome,
    required this.dosagemUnica,
    required this.intervalo,
    required this.horarioInicio,
    required this.dataInicio,
    required this.dataFim,
  });
}