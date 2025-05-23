class CustomerModel {
  final String idcliente;
  final String? idpersona;
  final String nit;
  final String nombres;
  final String? tipodoc;
  final String? celular;
  final String? color;
  final String? direccion;
  final String? representante;
  final String? codigo;
  final String? latitud;
  final String? longitud;
  final String? idsubcatcliente;
  final String? link;

  CustomerModel({required this.idcliente, this.idpersona, required this.nit, required this.nombres,
    this.tipodoc,
    this.celular, this.color, this.direccion, this.codigo, this.latitud,
    this.longitud, this.idsubcatcliente, this.representante, this.link});

  factory CustomerModel.fromJson(Map<String, dynamic> json){
    return CustomerModel(
      idcliente: json['idcliente'],
      idpersona: json['idpersona'],
      codigo: json['codigo'],
      nombres: json['nombres'],
      tipodoc: json['tipodoc'],
      nit: json['nit'],
      celular: json['celular'],
      color: json['color'],
      direccion: json['direccion'],
      representante: json['representante'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      idsubcatcliente: json['idsubcatcliente'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "idcliente": idcliente,
      "idpersona": idpersona,
      "codigo": codigo,
      "nombres": nombres,
      "tipodoc": tipodoc,
      "nit": nit,
      "color": color,
      "direccion": direccion,
      "representante": representante,
      "celular": celular,
      "longitud": longitud,
      "latitud": latitud,
      "idsubcatcliente": idsubcatcliente,
      "link": link,
    };
  }
}