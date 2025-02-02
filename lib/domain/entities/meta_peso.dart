class MetaPeso {
  final int id;
  final int idUsuario;
  final double pesoPretendido;
  final String dataInicio;
  final String dataLimite;
  final bool foiAtingido;

  MetaPeso({
    required this.id,
    required this.idUsuario,
    required this.pesoPretendido,
    required this.dataInicio,
    required this.dataLimite,
    required this.foiAtingido,
  });

  // Fábrica para criar MetaPeso a partir de um JSON
  factory MetaPeso.fromJson(Map<String, dynamic> json) {
    return MetaPeso(
      id: json['id'],
      idUsuario: json['id_usuario'],
      pesoPretendido: json['peso_pretendido'].toDouble(),
      dataInicio: json['data_inicio'],
      dataLimite: json['data_limite'],
      foiAtingido: json['foi_atingido'],
    );
  }

  // Método para converter MetaPeso em JSON para envio ao backend
  Map<String, dynamic> toJson() {
    return {
      'peso_pretendido': pesoPretendido,
      'data_inicio': dataInicio,
      'data_limite': dataLimite,
      'foi_atingido': foiAtingido,
    };
  }
}
