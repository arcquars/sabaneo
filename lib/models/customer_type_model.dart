class CustomerTypeModel {
  final String idsubcatcliente;
  final String nombre;

  CustomerTypeModel({required this.idsubcatcliente, required this.nombre});

  factory CustomerTypeModel.fromJson(Map<String, dynamic> json){
    return CustomerTypeModel(
      idsubcatcliente: json['idsubcatcliente'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "idsubcatcliente": idsubcatcliente,
      "nombre": nombre,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerTypeModel &&
              runtimeType == other.runtimeType &&
              idsubcatcliente == other.idsubcatcliente;

  @override
  int get hashCode => idsubcatcliente.hashCode;
}