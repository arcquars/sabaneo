import 'package:flutter/material.dart';

class Cart {
 late final int? id;
 final String? productId;
 final String? codigo;
 final String? productName;
 final double? initialPrice;
 final double? productPrice;
 final ValueNotifier<int>? quantity;
 final String? unitTag;
 final String? image;

 Cart(
     {required this.id,
     required this.productId,
     required this.codigo,
     required this.productName,
     required this.initialPrice,
     required this.productPrice,
     required this.quantity,
     required this.unitTag,
     required this.image});

 Cart.fromMap(Map<dynamic, dynamic> data)
     : id = data['id'],
       productId = data['productId'],
       codigo = data['codigo'],
       productName = data['productName'],
       initialPrice = data['initialPrice'],
       productPrice = data['productPrice'],
       quantity = ValueNotifier(data['quantity']),
       unitTag = data['unitTag'],
       image = data['image'];

 Map<String, dynamic> toMap() {
   return {
     'id': id,
     'productId': productId,
     'codigo': codigo,
     'productName': productName,
     'initialPrice': initialPrice,
     'productPrice': productPrice,
     'quantity': quantity?.value,
     'unitTag': unitTag,
     'image': image,
   };
 }

 Map<String, dynamic> quantityMap() {
    return {
      'productId': productId,
      'quantity': quantity!.value,
    };
  }
}