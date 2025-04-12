class Product {
  final String idproducto;
  final String codigo;
  final double transito;
  final String codigofabrica;
  final String nombre;
  final String marca;
  final String pais;
  final double preciobs;
  final double preciosus;
  final String unidad;
  final String link;
  final String image;
  final String? oem;
  final String tipo;
  final String? kit;
  final String stock;
  final double cantidad;
  final String? car1;
  final String? car2;
  final String? car3;

  Product({required this.idproducto, required this.codigo, required this.transito,
          required this.codigofabrica, required this.nombre, required this.marca,
          required this.pais, required this.preciobs, required this.preciosus, 
          required this.unidad, required this.link, required this.image, this.oem,
          required this.tipo, this.kit, required this.stock, required this.cantidad,
          this.car1, this.car2, this.car3});

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
      idproducto: json['idproducto'],
      codigo: json['codigo'],
      transito: double.parse(json['transito']),
      codigofabrica: json['codigofabrica'],
      nombre: json['nombre'],
      marca: json['marca'],
      pais: json['pais'],
      preciobs: double.parse(json['preciobs']),
      preciosus: double.parse(json['preciosus']),
      unidad: json['unidad'],
      link: json['link'],
      image: json['image'],
      oem: json['oem'],
      tipo: json['tipo'],
      kit: json['kit'],
      stock: json['stock'],
      cantidad: double.parse(json['cantidad']),
      car1: json['car1'],
      car2: json['car2'],
      car3: json['car3'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "idproducto": idproducto,
      "codigo": codigo,
      "transito": transito,
      "codigofabrica": codigofabrica,
      "nombre": nombre,
      "marca": marca,
      "pais": pais,
      "preciobs": preciobs,
      "preciosus": preciosus,
      "unidad": unidad,
      "link": link,
      "image": image,
      "oem": oem,
      "tipo": tipo,
      "kit": kit,
      "stock": stock,
      "cantidad": cantidad,
      "car1": car1,
      "car2": car2,
      "car3": car3,
    };
  }

  String get cars {
    String result = "";
    if(car1 != null && car1 != ''){
      result += '$car1|';
    }
    if(car2 != null && car2 != ''){
      result += '$car2|';
    }
    if(car3 != null){
      result += '$car3';
    }
    return result;
  }
}