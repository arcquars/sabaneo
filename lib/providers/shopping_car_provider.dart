import 'package:flutter/material.dart';
import 'package:sabaneo_2/models/product_car_model.dart';

class ShoppingCarProvider with ChangeNotifier {
    final List<ProductoCar> _productsCar = [];

    List<ProductoCar> get products => _productsCar;

    void addProduct(ProductoCar product) {
      _productsCar.add(product);
      notifyListeners();
    }

    void removeProduct(String id) {
      _productsCar.removeWhere((product) => product.id == id);
      notifyListeners();
    }

    double getTotal() {
      return _productsCar.fold(0, (total, product) => total + (product.price * product.quantity));
    }
  }