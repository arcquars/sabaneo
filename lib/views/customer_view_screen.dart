import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabaneo_2/models/customer_model.dart';
import 'package:sabaneo_2/models/customer_type_model.dart';
import 'package:sabaneo_2/services/config_service.dart';
import 'package:sabaneo_2/services/customer_service.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';

class CustomerViewScreen extends StatelessWidget {
  const CustomerViewScreen({super.key
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
              Text('Cliente'),
            ],
          ),
          centerTitle: true, // Opcional: Centrar el título
          backgroundColor: Color(0xFFFD7E14),
        ),
        body: CustomerViewContent()
    );
  }
}

class CustomerViewContent extends StatefulWidget {

  const CustomerViewContent({super.key});

  @override
  _CustomerViewContentStatefulState createState() => _CustomerViewContentStatefulState();
}

class _CustomerViewContentStatefulState extends State<CustomerViewContent> {
  late String customerId;
  bool _isInitialized= false;

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
  String? _idpersona;
  File? _imagenFrontis;
  String _customer_url = "";
  List<dynamic>? _documentTypes;

  List<CustomerTypeModel> _customerTypes = [];
  CustomerTypeModel? _customerTypeSelection;
  String? _documentTypeSelection;
  bool _loading = true;

  CustomerModel? _customerEdit;
  @override
  void initState() {
    _documentTypes = ConfigService.documentTypes;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final route = ModalRoute.of(context);
      if (route != null) {
        customerId = route.settings.arguments as String;
        _loadCustomerTypes();
        _isInitialized = true;
      }
    }
  }

  void _loadCustomerTypes() async {
    try {
      Map<String, String> filters = {
        "idcliente": customerId,
      };

      final List<CustomerTypeModel> types = await _customerService.getCustomerTypes();
      final CustomerModel? customerTemp = await _customerService.getCustomer(filters);
      setState(() {
        _customerTypes = types;

        debugPrint("cccccc eeeeee 1 ");
        _customerEdit = customerTemp;
        debugPrint("cccccc eeeeee 2 ");
        _nitController.text = _customerEdit!.nit;
        _idpersona = _customerEdit!.idpersona;
        _codigoController.text = _customerEdit!.codigo!;
        _documentTypeSelection = _customerEdit!.tipodoc;
        _nombreController.text = _customerEdit!.nombres;
        _telefonoController.text = _customerEdit!.celular!;
        _direccionController.text = _customerEdit!.direccion!;
        _representanteLegalController.text = _customerEdit!.representante!;
        debugPrint("cccccc eeeeee 3 ");
        _coordenadasController.text = "Lat: ${_customerEdit!.latitud!}, Lng: ${_customerEdit!.longitud!}";
        debugPrint("cccccc eeeeee 4 ${_customerEdit!.latitud!} - ${_customerEdit!.longitud!}");
        // _ubicacion = LatLng(37.7749, -122.4194);
        _ubicacion = LatLng(double.parse(_customerEdit!.latitud!), double.parse(_customerEdit!.longitud!));
        debugPrint("cccccc eeeeee 5 $_ubicacion");
        _customer_url = _customerEdit!.link!;
        _customerTypeSelection = types.firstWhere(
              (customer) => customer.idsubcatcliente == _customerEdit!.idsubcatcliente,
        );
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
    final result = await Navigator.pushNamed(context, '/mapa_direccion', arguments: {"latitude": _customerEdit!.latitud, "longitude":_customerEdit!.longitud}) as LatLng?;
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

  Future<String?> pickAndEncodeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    }
    return null;
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

      _createCustomer();
      // Lógica para guardar el cliente en tu backend o base de datos
    }
  }

  Future<void> _createCustomer() async {
    var base64 = "";
    if(_imagenFrontis != null){
      var bytes = await _imagenFrontis!.readAsBytes();
      base64 = base64Encode(bytes);
    }
    try{
      var resultado = await _customerService.createCustomer(
          customerId,
          _idpersona!,
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
          base64);

      mostrarAlertaSimple(context, resultado);
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("$resultado")),
      // );
    } on Exception catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if(_loading){
      return CircularProgressIndicator();
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
                                labelText: "NIT",
                                hintText: "Ingrese el NIT cliente"
                            ),
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
                  debugPrint("eeee ppp ooo:: $_ubicacion");
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
              if(_customer_url != "" && _imagenFrontis == null)
                Container(
                    width: 80.0, // Ancho deseado
                    height: 115.0, // Altura deseada
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle, // Forma circular
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage('${_customer_url}'),
                        ),
                        // border: Border.all(
                        //   color: Color(0xff516966), // Color del borde
                        //   width: 1.0,         // Ancho del borde
                        // ),
                        // borderRadius: BorderRadius.circular(5.0)
                    )
                ),
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
}