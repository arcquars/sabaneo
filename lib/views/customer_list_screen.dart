import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                FaIcon(FontAwesomeIcons.users), // Icono a la izquierda
                SizedBox(width: 8), // Espaciado entre icono y texto
                Text('Clientes'),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.squarePlus),
                tooltip: 'Crear nuevo',
                onPressed: () {
                  Navigator.pushNamed(context, "/customer-create");
                },
              ),
            ],
            centerTitle: true, // Opcional: Centrar el título
            backgroundColor: Color(0xFFFD7E14),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            
          ],
        )
      );
  }
}