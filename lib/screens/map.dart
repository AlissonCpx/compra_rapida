import 'package:compra_rapida_2/models/destino.dart';
import 'package:compra_rapida_2/models/market.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(0, 0), zoom: 16);
  Set<Marker> _marcadores = {};
  bool habilitaBotao = false;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  final _controllerDestino = TextEditingController();

  _adicionarListenerLocalizacao() {
    var geoLocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    Position pose;

    geoLocator.getPositionStream(locationOptions).listen((Position position) {
      _exibirMarcador(position);
      pose = position;
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);
      _movimentarCamera(_posicaoCamera);
    });
    print(pose);
  }

  _recuperaUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if (position != null) {
        _exibirMarcador(position);
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _movimentarCamera(_posicaoCamera);
      }
    });
  }

  _exibirMarcador(Position local) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: "Meu Local"),
          icon: icone);
      setState(() {
        _marcadores.add(marcadorPassageiro);
      });
    });
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _localizaEndereco() async {
    String enderecoDestino = _controllerDestino.text;

    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEnderecos =
          await Geolocator().placemarkFromAddress(enderecoDestino);

      if (listaEnderecos != null && listaEnderecos.length > 0) {
        Placemark endereco = listaEnderecos[0];
        setState(() {
          _posicaoCamera = CameraPosition(
              target: LatLng(
                  endereco.position.latitude, endereco.position.longitude),
              zoom: 19);
          _movimentarCamera(_posicaoCamera);
        });
      }
    }
  }

  _confirmaEndereco() async {
    String enderecoDestino = _controllerDestino.text;

    if (enderecoDestino.isNotEmpty) {
      List<Placemark> listaEnderecos =
          await Geolocator().placemarkFromAddress(enderecoDestino);

      if (listaEnderecos != null && listaEnderecos.length > 0) {
        Placemark endereco = listaEnderecos[0];

        Destino destino = Destino();
        destino.cidade = endereco.administrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.numero = endereco.subThoroughfare;

        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;
        Navigator.pop(context, destino);
      }
    }
  }

  _habilitaBotao() {
    if (_controllerDestino.text.isNotEmpty) {
      setState(() {
        habilitaBotao = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _recuperaUltimaLocalizacaoConhecida();
      _adicionarListenerLocalizacao();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Definir Endereço"),
        centerTitle: true,
      ),
      body: Container(
          child: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            onMapCreated: _onMapCreated,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: _marcadores,
          ),
          /*Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white),
                  child: TextField(
                    controller: _controllerDestino,
                    readOnly: true,
                    decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, top: 0),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                        ),
                        hintText: "Meu local",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, top: 16)),
                  ),
                ),
              )),*/
          Positioned(
              top: 275,
              left: 0,
              right: 0,
              child: Image.asset(
                "images/passageiro.png",
                width: 50,
                height: 50,
              )),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _controllerDestino,
                            readOnly: false,
                            decoration: InputDecoration(
                                icon: Container(
                                  margin: EdgeInsets.only(left: 20, top: 0),
                                  width: 10,
                                  height: 10,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                  ),
                                ),
                                hintText: "Digite endereço para entrega",
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 15, top: 16)),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: PhysicalModel(
                              color: Colors.transparent,
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: IconButton(
                                    onPressed: () {
                                      _habilitaBotao();
                                      _localizaEndereco();
                                    },
                                    icon: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    )),
                              ),
                              elevation: 5,
                              borderRadius: BorderRadius.circular(10),
                            ))
                      ],
                    )),
              )),
          Positioned(
              right: 0,
              left: 0,
              bottom: 15,
              child: Padding(
                padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                child: RaisedButton(
                    child: Text(
                      "Confirmar Endereço",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: habilitaBotao ? Colors.green : Colors.grey,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: habilitaBotao
                        ? () {
                            _confirmaEndereco();
                          }
                        : null),
              ))
        ],
      )),
    );
  }
}
