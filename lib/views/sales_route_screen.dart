
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/providers/user_provider.dart';

class SalesRouteScreen extends StatelessWidget {
  const SalesRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                FaIcon(FontAwesomeIcons.store), // Icono a la izquierda
                SizedBox(width: 8), // Espaciado entre icono y texto
                Text('Rutas de ventas'),
              ],
            ),
            centerTitle: true, // Opcional: Centrar el título
            backgroundColor: Color(0xFFFD7E14),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            DatePickerButton(),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: 
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-17.3935, -66.1570), // Coordenadas de Cochabamba, Bolivia
                    zoom: 14.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    // Controlador del mapa
                  },
                ),
            )
          ],
        )
      );
  }
}

class DatePickerButton extends StatefulWidget {
  @override
  _DatePickerButtonState createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  DateTime? _selectedDate;

  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('Seleccionar fecha'),
        ),
        SizedBox(height: 5),
        Text(
          _selectedDate == null
              ? 'Ninguna fecha seleccionada'
              : 'Fecha seleccionada: ${_selectedDate!.toLocal().toString().split(" ")[0]}',
        ),
      ],
    );
  }
}