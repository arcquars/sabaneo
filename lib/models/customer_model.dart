class CustomerModel {
  final String idcliente;
  final String nit;
  final String nombres;
  final String color;
  final String codigo;

  CustomerModel({required this.idcliente, required this.nit, required this.nombres, required this.color, required this.codigo});

  factory CustomerModel.fromJson(Map<String, dynamic> json){
    return CustomerModel(
      idcliente: json['idcliente'],
      codigo: json['codigo'],
      nombres: json['nombres'],
      nit: json['nit'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "idcliente": idcliente,
      "codigo": codigo,
      "nombres": nombres,
      "nit": nit,
      "color": color,
    };
  }
}