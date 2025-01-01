class MetaPeso {
  final String id;
  final String idUsuario; 
  final double pesoPretendido; 
  final DateTime dataInicio; 
  final DateTime dataLimite; 
  final bool foiAtingido; 

  MetaPeso({
    required this.id,
    required this.idUsuario,
    required this.pesoPretendido,
    required this.dataInicio,
    required this.dataLimite,
    required this.foiAtingido,
  });
}
