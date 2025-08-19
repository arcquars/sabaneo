import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/database/db_helper.dart';
import 'package:sabaneo_2/login/presentation/form/form_login.dart';
import 'package:sabaneo_2/login/presentation/view/auth_drawer.dart';
import 'package:sabaneo_2/models/caracteristica_model.dart';
import 'package:sabaneo_2/models/cart_model.dart';
import 'package:sabaneo_2/models/item_model.dart';
import 'package:sabaneo_2/models/product_model.dart';
import 'package:sabaneo_2/observers/session_observer.dart';
import 'package:sabaneo_2/providers/cart_provider.dart';
import 'package:sabaneo_2/providers/shopping_car_provider.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:sabaneo_2/services/config_service.dart';
import 'package:sabaneo_2/services/store_service.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';
import 'package:sabaneo_2/views/cart_screen.dart';
import 'package:sabaneo_2/views/customer_create_screen.dart';
import 'package:sabaneo_2/views/customer_list_screen.dart';
import 'package:sabaneo_2/views/customer_view_screen.dart';
import 'package:sabaneo_2/views/sales_route_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Necesario antes de SharedPreferences
  await ConfigService.loadConfig();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userRole = prefs.getString('role') ?? "salesman";
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider()..loadUserSession(),
        ),
        ChangeNotifierProvider(create: (context) => ShoppingCarProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, role: userRole),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppBar con Menú',
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: navigatorKey,
      navigatorObservers: [SessionObserver(navigatorKey)],
      // home: isLoggedIn? HomeScreen(isLoggedIn: isLoggedIn, role: role) : FormLogin(),
      // initialRoute: isLoggedIn? '/home' : '/login',
      initialRoute: '/home',
      routes: {
        '/login': (context) => FormLogin(),
        '/home': (context) => HomeScreen(isLoggedIn: isLoggedIn, role: role),
        '/sales-route': (context) => SalesRouteScreen(),
        '/customer-list': (context) => CustomerListScreen(),
        '/customer-create': (context) => CustomerCreateScreen(),
        '/customer-view': (context) => CustomerViewScreen(),
        '/mapa_direccion': (context) => const MapaDireccion(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const HomeScreen({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.store),
            SizedBox(width: 8),
            Text(ConfigService.appName),
          ],
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
          ),
        ],
        leading: badges.Badge(
          badgeContent: Consumer<CartProvider>(
            builder: (context, value, child) {
              return Text(
                value.getCounter().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          position: const badges.BadgePosition(start: 30, bottom: 30),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ),
        backgroundColor: Color(0xFFFD7E14),
      ),
      // endDrawer: isLoggedIn? AuthDrawer(userRole: role?? "Vendedor") : GuestDrawer(),
      endDrawer: AuthDrawer(userRole: role ?? "Vendedor"),

      // body: isLoggedIn? SalesmanContent() : Center(child: Text('Contenido Principal ${ConfigService.apiBaseUrl}')),
      body: SalesmanContent(),
    );
  }
}

class SalesmanContent extends StatefulWidget {
  const SalesmanContent({super.key});

  @override
  _SalesmanContentStatefulState createState() =>
      _SalesmanContentStatefulState();
}

class _SalesmanContentStatefulState extends State<SalesmanContent> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _oemController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  bool _isCheckedSaldo = true;

  late UserProvider _userProvider;

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  final StoreService _storeService = StoreService();
  late Future<List<Product>> _products;

  List<Caracteristica> _caracteristicas = [];
  List<TextEditingController> controladores = [];

  String? _selectedSaldo = "0";
  final List<Item> _saldos = [
    Item(id: "0", name: "TODOS"),
    Item(id: "1", name: "Saldo Almacen"),
    Item(id: "2", name: "Saldo Empresa"),
  ];

  final DBHelper dbHelper = DBHelper();

  @override
  void dispose() {
    _marcaController.dispose();
    for (var controlador in controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _products = _storeService.getProducts();
    getServiceCaracteristicas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _search(true);
      }
    });
  }

  Future<void> _search(bool isAdd) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String idCar = "";
    String nomCar = "";
    _caracteristicas.forEach((caracteristica) {
      idCar += "${caracteristica.idcaracteristica}_";
      nomCar += "${caracteristica.nombre}_";
    });

    final int start = (_currentPage * _itemsPerPage) - _itemsPerPage;
    Map<String, String> filters = {
      "codigo": _codigoController.text,
      "marca": _marcaController.text,
      "oem": _oemController.text,
      "descripcion": _descripcionController.text,
      // "saldo": _isCheckedSaldo.toString(),
      "saldo": _selectedSaldo!,
      "idcar": idCar,
      "nomcar": nomCar,
      "start": start.toString(),
      "limit": _itemsPerPage.toString(),
    };

    int indexCar = 0;
    List<MapEntry<String, String>> carEntries = [];
    for (var car in _caracteristicas) {
      carEntries.add(
        MapEntry("car${indexCar + 1}", controladores[indexCar++].text),
      );
    }
    filters.addEntries(carEntries);

    // filters.addEntries(newEntries)
    setState(() {
      // _products = _storeService.getProductsCar(filters);
      if (isAdd) {
        _products.then((products) async {
          products.addAll(await _storeService.getProductsCar(filters));
        });
      } else {
        _products = _storeService.getProductsCar(filters);
      }

      _currentPage++;
      _isLoading = false;
    });
  }

  Future<void> getServiceCaracteristicas() async {
    try {
      _caracteristicas = await _storeService.getCaracteristica();
      controladores =
          _caracteristicas
              .map((dato) => TextEditingController(text: ""))
              .toList();
    } on Exception catch (e) {
      _caracteristicas = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    void saveData(int index, Product product) {
      dbHelper
          .insert(
            Cart(
              id: index,
              productId: product.idproducto,
              codigo: product.codigo,
              productName: product.nombre,
              initialPrice: product.preciobs,
              productPrice: product.preciobs,
              quantity: ValueNotifier(1),
              unitTag: product.unidad,
              image: product.image,
            ),
          )
          .then((value) {
            cart.addTotalPrice(product.preciobs.toDouble());
            cart.addCounter();
            debugPrint('Product Added to cart');
          })
          .onError((error, stackTrace) {
            debugPrint(error.toString());
          });
    }

    return Column(
      children: [
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            // color: Color(0xfff2f2f2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
            ],
          ),
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Acción del botón
                  _showModalBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // Radio de las esquinas
                    side: BorderSide(
                      color: const Color(0xfffd7e14), // Color del borde
                      width: 1, // Grosor del borde
                    ),
                  ),
                ),
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 1.0, height: 15),
                    Icon(
                      Icons.filter_alt_outlined,
                      color: const Color(0xfffd7e14),
                      size: 26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay productos disponibles.'));
              } else {
                List<Product> products = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        debugPrint("xxxxx: ${product.idproducto}");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80.0, // Ancho deseado
                              height: 115.0, // Altura deseada
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                // Forma circular
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'http://selkisbolivia.com/${product.image}',
                                  ),
                                ),
                                border: Border.all(
                                  color: Color(0xff516966),
                                  // Color del borde
                                  width: 1.0, // Ancho del borde
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Container(
                                            // color: Color(0xfffd7e14),
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color:
                                                  (double.parse(product.stock) >
                                                          0)
                                                      ? Color(0xfffd7e14)
                                                      : Color(0xff515c69),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                debugPrint(
                                                  "test tab....${product.idproducto} ",
                                                );
                                                // final productCar = ProductoCar(id: product.idproducto, name: product.nombre, price: product.preciobs);
                                                // Provider.of<ShoppingCarProvider>(context, listen: false).addProduct(productCar);
                                                saveData(index, product);
                                                // Crear el SnackBar
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                    'Se añadio el producto ${product.nombre} al carrito de compras',
                                                  ),
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ), // Duración del SnackBar
                                                  // action: SnackBarAction(
                                                  //   label: 'Deshacer',
                                                  //   onPressed: () {
                                                  //     // Acción a realizar cuando se presiona 'Deshacer'
                                                  //   },
                                                  // ),
                                                );

                                                // Mostrar el SnackBar
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(snackBar);
                                              },
                                              child: Icon(
                                                Icons.shopping_cart,
                                                color: Color(0xffffffff),
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ${product.codigo}',
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xfffd7e14),
                                          ),
                                        ),
                                      ],
                                      // recognizer: _tapGestureRecognizer,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  SizedBox(
                                    height:
                                        product.nombre.length > 50 ? 50 : 25,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            product.nombre.length > 50
                                                ? "${product.nombre.substring(0, 50)}..."
                                                : product.nombre,
                                          ),
                                          // Añade más widgets según sea necesario
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.cars,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Bs. ${product.preciobs}",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.marca,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Marca',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${product.stock}/${product.cantidad}",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Stock',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xfffd7e14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    // Dividir la lista de datos en pares
    List<List<Caracteristica>> paresDeDatos = [];
    for (int i = 0; i < _caracteristicas.length; i += 2) {
      paresDeDatos.add(
        _caracteristicas.sublist(
          i,
          i + 2 > _caracteristicas.length ? _caracteristicas.length : i + 2,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Permite que el BottomSheet ocupe más espacio si es necesario
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Padding(
              // padding: const EdgeInsets.all(8.0),
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // Ajusta la altura al contenido
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Busqueda',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xfffd7e14),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: _codigoController,
                                  decoration:
                                      SabaneoInputDecoration.defaultDecoration(
                                        labelText: "Codigo",
                                        hintText: "",
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8), // Espacio entre columnas
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                InputDecorator(
                                  // Aplica la decoración que ya tienes definida.
                                  decoration: InputDecoration(
                                    // hintText: "SALDO ...",
                                    border: const OutlineInputBorder(), // Borde por defecto
                                    focusedBorder: const OutlineInputBorder( // Borde cuando está activo
                                      borderSide: BorderSide(color: Color(0xffe8a63f), width: 2.0),
                                    ),
                                    labelStyle: const TextStyle(color: Colors.grey), // Estilo por defecto del label
                                    floatingLabelStyle: const TextStyle(color: Color(0xffe8bb3f)), // Estilo del label cuando está activo
                                    contentPadding: const EdgeInsets.all(0),
                                  ),
                                  isEmpty: _selectedSaldo == "0",
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      // El valor actual seleccionado. Debe ser null si no hay ninguno.
                                      isExpanded: true,
                                      value: _selectedSaldo,
                                      // Icono de la flecha
                                      // iconSize: 24,
                                      // elevation: 16,
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                      onChanged: (String? newValue) {
                                        debugPrint("xxxx pdm 1:: $newValue ");
                                        setStateDialog(() {
                                          _descripcionController.clear();
                                          _selectedSaldo =
                                              newValue; // Actualiza el estado con el nuevo valor
                                          debugPrint(
                                            "xxxx pdm 2:: $_selectedSaldo ",
                                          );
                                        });
                                      },
                                      items:
                                      _saldos.map<DropdownMenuItem<String>>((
                                          Item value,
                                          ) {
                                        // Mapea la lista de Strings a DropdownMenuItem
                                        return DropdownMenuItem<String>(
                                          value: value.id,
                                          // El valor real de la opción
                                          child: Text(
                                            value.name,
                                          ), // El texto visible de la opción
                                        );
                                      }).toList(), // Convierte el iterable a una lista
                                    ),
                                  ),
                                )





                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: 4.0),
                          TextField(
                            controller: _descripcionController,
                            decoration:
                                SabaneoInputDecoration.defaultDecoration(
                                  labelText: "Descripcion",
                                  hintText: "",
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          // Primera columna
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: _marcaController,
                                  decoration:
                                      SabaneoInputDecoration.defaultDecoration(
                                        labelText: "Marca",
                                        hintText: "",
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8), // Espacio entre columnas
                          // Segunda columna
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: _oemController,
                                  decoration:
                                      SabaneoInputDecoration.defaultDecoration(
                                        labelText: "OEM",
                                        hintText: "",
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      _caracteristicas.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _caracteristicas.length,
                            itemBuilder: (context, index) {
                              if (index < paresDeDatos.length) {
                                List<Caracteristica> parActual =
                                    paresDeDatos[index];
                                return Row(
                                  children: List.generate(parActual.length, (
                                    i,
                                  ) {
                                    int controladorIndex = index * 2 + i;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextField(
                                          controller:
                                              controladores[controladorIndex],
                                          decoration:
                                              SabaneoInputDecoration.defaultDecoration(
                                                labelText:
                                                    _caracteristicas[controladorIndex]
                                                        .nombre,
                                                hintText: "",
                                              ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              }
                            },
                          ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              // Acción al presionar el botón
                              Navigator.pop(context);
                              _codigoController.text = "";
                              _marcaController.text = "";
                              _oemController.text = "";
                              _descripcionController.text = "";
                              _isCheckedSaldo = false;
                              _selectedSaldo = "0";

                              for (var controlador in controladores) {
                                controlador.text = "";
                              }
                              _search(false);
                            },
                            style: SabaneoButtonStyles.primaryButtonStyle(),
                            child: Text('Limpiar filtros'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Acción al presionar el botón
                              Navigator.pop(context);
                              _currentPage = 1;

                              _search(false);
                            },
                            style: SabaneoButtonStyles.primaryButtonStyle(),
                            child: Text('Buscar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
