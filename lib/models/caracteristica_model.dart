class Caracteristica {
  final String idcaracteristica;
  final String nombre;
  final String estado;
  final String numero;

  Caracteristica({required this.idcaracteristica, required this.nombre, required this.estado,
          required this.numero});

  factory Caracteristica.fromJson(Map<String, dynamic> json){
    return Caracteristica(
      idcaracteristica: json['idcaracteristica'],
      nombre: json['nombre'],
      estado: json['estado'],
      numero: json['numero']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "idcaracteristica": idcaracteristica,
      "nombre": nombre,
      "estado": estado,
      "numero": numero,
    };
  }
}