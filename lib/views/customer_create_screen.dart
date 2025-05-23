import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabaneo_2/models/customer_type_model.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:sabaneo_2/services/config_service.dart';
import 'package:sabaneo_2/services/customer_service.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';
import 'package:sabaneo_2/utils/location_util.dart';

class CustomerCreateScreen extends StatelessWidget {
  const CustomerCreateScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                FaIcon(FontAwesomeIcons.userGear), // Icono a la izquierda
                SizedBox(width: 8), // Espaciado entre icono y texto
                Text('Crear Cliente'),
              ],
          ),
          centerTitle: true, // Opcional: Centrar el título
          backgroundColor: Color(0xFFFD7E14),
        ),
        body: CustomerCreateForm()
      );
  }
}

class CustomerCreateForm extends StatefulWidget {
  const CustomerCreateForm({super.key});

  @override
  State<CustomerCreateForm> createState() => _CustomerCreateFormState();
}

class _CustomerCreateFormState extends State<CustomerCreateForm> {
  final CustomerService _customerService = CustomerService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _representanteLegalController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _coordenadasController = TextEditingController();
  LatLng? _ubicacion;
  File? _imagenFrontis;
  List<dynamic>? _documentTypes;

  late UserProvider _userProvider;

  List<CustomerTypeModel> _customerTypes = [];
  CustomerTypeModel? _customerTypeSelection;
  String? _documentTypeSelection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _documentTypes = ConfigService.documentTypes;
    _loadCustomerTypes();

  }

  void _loadCustomerTypes() async {
    try {
      final types = await _customerService.getCustomerTypes();
      setState(() {
        _customerTypes = types;
        _customerTypeSelection = types.isNotEmpty ? types.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      // Manejo de errores, por ejemplo, mostrar un mensaje al usuario
    }
  }

  Future<void> _seleccionarUbicacion(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/mapa_direccion') as LatLng?;
    if (result != null) {
      setState(() {
        _ubicacion = result;
        _coordenadasController.text = 'Lat: ${_ubicacion!.latitude.toStringAsFixed(6)}, Lng: ${_ubicacion!.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imagenFrontis = File(pickedFile.path);
      } else {
        debugPrint('No se tomó ninguna foto.');
      }
    });
  }

  void _guardarCliente() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes acceder a los valores de los controladores y _ubicacion y _imagenFrontis
      debugPrint('Codigo: ${_codigoController.text}');
      debugPrint('Nombre: ${_nombreController.text}');
      debugPrint('NIT: ${_nitController.text}');
      debugPrint('Representante Legal: ${_representanteLegalController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Ubicación: $_ubicacion');
      debugPrint('Imagen Frontis: $_imagenFrontis');
      debugPrint('Tipo de cliente: ${_customerTypeSelection?.nombre}');

      setState(() {
        _loading = true;
      });
      _createCustomer();
      // Lógica para guardar el cliente en tu backend o base de datos
    }
  }

  Future<String?> pickAndEncodeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  Future<void> _createCustomer() async {
    final bytes = await _imagenFrontis!.readAsBytes();
    try{
      var resultado = await _customerService.createCustomer(
          'nuevo',
          'nuevo',
          _codigoController.text,
          _documentTypeSelection!,
          _nitController.text,
          _complementoController.text,
          _nombreController.text,
          _telefonoController.text,
          _direccionController.text,
          _representanteLegalController.text,
          _customerTypeSelection!.idsubcatcliente,
          _ubicacion!.latitude.toString(),
          _ubicacion!.longitude.toString(),
          base64Encode(bytes));
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(resultado)
      //   ),
      // );
      setState(() {
        _loading = false;
      });
      mostrarAlertaSimple(context, resultado);
    } on Exception catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    if(_loading){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _codigoController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                  labelText: "Codigo",
                  // hintText: "Ingrese el nombre del cliente"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el codigo del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _documentTypeSelection,
                items: _documentTypes?.map((tipo) {
                  debugPrint("dddd: $tipo");
                  return DropdownMenuItem<String>(
                    value: tipo['id'],
                    child: Text(
                      tipo['name'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (nuevoTipo) {
                  _documentTypeSelection = nuevoTipo;
                  setState(() {
                    // _customerTypeSelection = nuevoTipo;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de documento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_documentTypeSelection == null || value == null || value.isEmpty) {
                    return 'Por favor, selecciona El tipo de documento.';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 8.0),
              Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nitController,
                              decoration: SabaneoInputDecoration.defaultDecoration(
                                  labelText: "Documento",
                                  hintText: "Ingrese el dato del documento"
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese el numero de documento.';
                                }
                                return null;
                              }
                            ),
                          ]
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _complementoController,
                              decoration: SabaneoInputDecoration.defaultDecoration(
                                  labelText: "Compl",
                                  hintText: "Compl"
                              ),
                            ),
                          ]
                      ),
                    ),
                  ]
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _nombreController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                  labelText: "Razon social",
                  // hintText: "Ingrese el nombre del cliente"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _telefonoController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Teléfono de Contacto",
                    hintText: ""
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _representanteLegalController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Representante Legal",
                    hintText: ""
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _direccionController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Dirección",
                    hintText: ""
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _coordenadasController,
                readOnly: true,
                decoration: SabaneoInputDecoration.defaultDecorationSuffixIcon(
                    labelText: "Coordenadas",
                    hintText: "",
                    suffixIcon: const Icon(Icons.map),
                    onPressedSuffixIcon: () {
                      _seleccionarUbicacion(context);
                    }
                ),
                validator: (value) {
                  if (_ubicacion == null || value == null || value.isEmpty) {
                    return 'Por favor, selecciona la ubicación en el mapa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<CustomerTypeModel>(
                value: _customerTypeSelection,
                items: _customerTypes.map((tipo) {
                  return DropdownMenuItem<CustomerTypeModel>(
                    value: tipo,
                    child: Text(tipo.nombre),
                  );
                }).toList(),
                onChanged: (nuevoTipo) {
                  debugPrint("eeee:: $nuevoTipo");
                  _customerTypeSelection = nuevoTipo;
                  setState(() {
                    // _customerTypeSelection = nuevoTipo;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto del Frontis'),
                style: SabaneoButtonStyles.primaryButtonStyle(),
                onPressed: _takePhoto,
              ),
              const SizedBox(height: 8.0),
              if (_imagenFrontis != null)
                SizedBox(
                  height: 100,
                  child: Image.file(_imagenFrontis!),
                ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _guardarCliente,
                style: SabaneoButtonStyles.secondaryButtonStyle(),
                child: const Text('Guardar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarAlertaSimple(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class MapaDireccion extends StatefulWidget {
  const MapaDireccion({super.key});

  @override
  State<MapaDireccion> createState() => _MapaDireccionState();
}

class _MapaDireccionState extends State<MapaDireccion> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Position? _position;
  bool _loading = true;

  bool _isInitialized= false;

  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-17.3936, -66.1571), // Cochabamba como ubicación inicial
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      bool hasUbicacion = false;
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final arguments = route.settings.arguments as Map<String, dynamic>;
        // _position = Position(longitude: arguments['longitude'], latitude: arguments['latitude']);
        _obtenerUbicacion(arguments);
        _isInitialized = true;
      } else {
        _obtenerUbicacion(null);
      }

    }
  }

  void _obtenerUbicacion(Map<String, dynamic>? posLatLon) async {
    debugPrint("sssss:: ");
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Los servicios de ubicación están deshabilitados.');
    }

    // Verificar los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Los permisos de ubicación están denegados permanentemente.');
    }

    double latitude = 0;
    double longitude = 0;
    if (posLatLon == null){
      _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude = _position!.latitude;
      longitude = _position!.longitude;
      _selectedLocation = LatLng(latitude, longitude);
    } else {
      debugPrint("eeee latitud::: ${posLatLon['latitude']}");
      latitude = double.parse(posLatLon['latitude'] as String);
      longitude = double.parse(posLatLon['longitude'] as String);

      _selectedLocation = LatLng(latitude, longitude);
    }
    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 18.0,
      );
      _loading = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    if(_loading){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            // myLocationEnabled: true,
            // myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            markers: _selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation!,
              ),
            },
          ),
          // Center(
          //   child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          // ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Retornar la posición seleccionada al cerrar la pantalla
                Navigator.pop(context, _selectedLocation);
              },
              child: Text('Confirmar ubicación'),
            ),
          ),
        ]
    );
  }
}