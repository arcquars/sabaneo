import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

part "text_field_general.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
          children: [
            FaIcon(FontAwesomeIcons.store), // Icono a la izquierda
            SizedBox(width: 8), // Espaciado entre icono y texto
            Text('SABANEO'),
          ],
        ),
        centerTitle: true, // Opcional: Centrar el título
        actions: [
          Builder( // 🔥 SOLUCIÓN: Usamos Builder para obtener el context correcto
            builder: (context) => IconButton(
              icon: Icon(Icons.menu), // Icono de hamburguesa
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // ✅ Abre el menú lateral derecho
              },
            ),
          ),
        ],
        backgroundColor: Color(0xFFFD7E14),
      ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingresar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54, 
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
                ),
              SizedBox(
                height: 20,
              ),
              _textFieldUsername(),
              SizedBox(
                height: 10,
              ),
              _textFieldPassword(),
              SizedBox(
                height: 15,
              ),
              _buttonLogin(),
              
              
            ], 
          ),
          

        ),
      ),
    );
  }
  
  Widget _textFieldUsername() {
    return TextFieldGeneral(
      labelText: 'Usuario',
      hintText: '',
      icon: Icons.person_2_outlined,
      onChanged: (value){},
    );
  }
  
  Widget _textFieldPassword() {
    return TextFieldGeneral(
      labelText: 'Contrasenia',
      hintText: '',
      onChanged: (value){},
      icon: Icons.password,
      obscureText: true
    );
  }

  Widget _buttonLogin(){
    return Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              
                child: SizedBox(
                  width: double.infinity, // ✅ Ocupa todo el ancho disponible
                  child: ElevatedButton(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8a63f),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                    child: Text('Entrar'),
                    ),
                    
                )
              );
  }

}