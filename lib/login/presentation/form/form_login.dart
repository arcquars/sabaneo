import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/main.dart';
import 'package:sabaneo_2/models/user_model.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:sabaneo_2/services/auth_service.dart';
import 'package:sabaneo_2/services/user_service.dart';

class FormLogin extends StatefulWidget {

  const FormLogin({super.key});

  @override
  FormLoginState createState() => FormLoginState();
}

class FormLoginState extends State<FormLogin> {
  
  final _formKey = GlobalKey<FormState>(); // ✅ Clave para manejar el formulario
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  final UserService _userService = UserService();
  User? _user; 

  final AuthService _authService = AuthService();
  

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validUser(username, password) async {
    
    final Map<String, dynamic> result = await _authService.login(username, password);
    final User? user = await _userService.getUser();

    setState(() {
      _user = user;
      if(!result['success']){
        setState(() {
          _errorMessage = result['message'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Login exitoso")),
        );
        setState(() {
          _errorMessage = null;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Formulario enviado correctamente")),
        // );

        Provider.of<UserProvider>(context, listen: false).login(_user!.name, _user!.username, _user!.email, _user!.role);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(isLoggedIn: true, role: _user!.role)), // ✅ Redirige a HomeScreen
        );
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      _validUser(username, password);
    }
  }

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
          backgroundColor: Color(0xFFFD7E14),
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null) // ✅ Mostrar mensaje de error
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
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
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    // BoxShadow(color: Colors.grey.withValues(), blurRadius: 5),
                  ],
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_2_outlined),
                    labelText: "Usuario",
                    hintText: "",
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese su usuario";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    // BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
                  ],
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    labelText: "Contrasenia",
                    hintText: "",
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese su contrasenia";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: SizedBox(
                  width: double.infinity, // ✅ Ocupa todo el ancho disponible
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8a63f),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                    child: Text('Iniciar Sesion'),
                    ),
                    
                )
              ),
              
              
            ], 
          ),
        ),
        )
      ),
    );
  }

  
}