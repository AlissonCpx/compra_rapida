import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combos/combos.dart';
import 'package:compra_rapida_2/models/destino.dart';
import 'package:compra_rapida_2/models/market.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/models/pedido.dart';
import 'package:compra_rapida_2/models/status.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/map.dart';
import 'package:compra_rapida_2/screens/orderInfo.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Order extends StatefulWidget {
  Pedido ped;

  Order(this.ped);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List itensPed;
  Destino destin;
  List<Market> mercados;
  String mercadoSelecionado = "Clique para selecionar:";
  bool habilitaBotao = false;
  double valorFrete = 0;
  bool loadingFrete = false;
  bool visivel = false;

  final enderecoController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(0, 0), zoom: 16);

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    itensPed = widget.ped.itens;

    _recebeSuperMercados();
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                    child: new Wrap(
                      children: <Widget>[
                        Container(
                            height: 383,
                            child: Expanded(
                              child: GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: _posicaoCamera,
                                onMapCreated: _onMapCreated,
                              ),
                            )),
                      ],
                    ),
                  ))
            ],
          );
        });
  }

  _recebeSuperMercados() async {
    Firestore db = Firestore.instance;

    List<DocumentSnapshot> documentList;
    documentList = (await db.collection("mercados").getDocuments()).documents;

    Market mercado = new Market();

    for (int i = 0; i < documentList.length; i++) {
      mercado.nome = documentList[i]["nome"];
      mercado.rua = documentList[i]["rua"];
      mercado.bairro = documentList[i]["bairro"];
      mercado.cep = documentList[i]["cep"];
      mercado.cidade = documentList[i]["cidade"];
      mercado.numero = documentList[i]["numero"];
      mercado.latitude = documentList[i]["latitude"];
      mercado.longitude = documentList[i]["longitude"];

      mercados.add(mercado);
    }
  }

  _habilitaBotao() {
    if (itensPed.isNotEmpty &&
        mercadoSelecionado != "Clique para selecionar:" &&
        enderecoController.text.isNotEmpty) {
      setState(() {
        habilitaBotao = true;
      });
    }
  }

  _calculaFrete() async {
    if (mercadoSelecionado != "Clique para selecionar:") {
      if (destin != null) {
        setState(() {
          loadingFrete = true;
          visivel = true;
        });

        Market merc = await Util.getMercados(mercadoSelecionado);

        double distanciaEmMetros = await Geolocator().distanceBetween(
            merc.latitude, merc.longitude, destin.latitude, destin.longitude);

        //Converte para KM
        double distanciaKm = distanciaEmMetros / 1000;

        double valor = distanciaKm * 2.2;
        double total = valor;
        if (widget.ped.itens.length > 15) {
          total = valor + 5.0;
        }

        setState(() {
          valorFrete = total;
        });

        setState(() {
          loadingFrete = false;
        });
      }
    }
  }

  _saveOrder() async {
    Firestore db = Firestore.instance;

    User user = await Util.getUsuario(widget.ped.userId);
    Market merc = await Util.getMercados(mercadoSelecionado);

    OrderPed ord = new OrderPed();
    ord.situacao = Status.AGUARDANDO;
    ord.mercado = merc;
    ord.destino = destin;
    ord.dataHoraPed = Timestamp.now();
    ord.itens = widget.ped.itens;
    ord.userClId = user;
    ord.idPedido = DateTime.now().millisecondsSinceEpoch.toString();
    ord.valorFrete = valorFrete;

    String id = ord.idPedido;

    await db.collection("pedidos").document().setData(ord.toMap());

    List<DocumentSnapshot> documentList;
    documentList = (await db
        .collection("pedidos")
        .where("idPedido", isEqualTo: id)
        .getDocuments())
        .documents;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderInfo(ord, documentList[0].documentID),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: habilitaBotao
            ? () {
                _saveOrder();
              }
            : null,
        backgroundColor: habilitaBotao ? Colors.lightBlueAccent : Colors.grey,
        child: Icon(Icons.navigate_next),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        title: Text("Pedido"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 10, 10),
                width: 400,
                height: 300,
                child: Card(
                    elevation: 10,
                    borderOnForeground: true,
                    child: Column(
                      children: <Widget>[
                        AppBar(
                          backgroundColor: Colors.deepPurple,
                          title: Text("Itens"),
                          automaticallyImplyLeading: false,
                          actions: <Widget>[

                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: widget.ped.itens.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text("${index + 1}."),
                                  title: Text(
                                    itensPed[index]["Item"],
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    itensPed[index]["comment"],
                                    maxLines: 1,
                                  ),
                                );
                              }),
                        ),
                        Divider(
                          color: Colors.deepPurple,
                        ),
                        Text("Quantidade de itens: ${itensPed.length}")
                      ],
                    )),
              ),
              Divider(),
              Text(
                "Supermercado: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: ListCombo<String>(
                  getList: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    return ["Atacadão", "Krolow", "Maxxi", "Stok Center"];
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(mercadoSelecionado),
                  ),
                  itemBuilder: (context, parameters, item) =>
                      ListTile(title: Text(item)),
                  onItemTapped: (item) {
                    _calculaFrete();
                    setState(() {
                      mercadoSelecionado = item;
                      _habilitaBotao();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Endereço para entrega: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              GestureDetector(
                onTap: () async {
                  final Destino dest = await Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Map()));

                  setState(() {
                    enderecoController.text = dest.rua + " ," + dest.numero;
                    destin = dest;
                    _calculaFrete();
                    _habilitaBotao();
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    autocorrect: true,
                    autofocus: false,
                    controller: enderecoController,
                    decoration: InputDecoration(
                        enabled: false,
                        hintText: 'Endereço: ',
                        prefixIcon: Icon(Icons.location_on),
                        labelStyle: TextStyle(color: Colors.redAccent)),
                    style: TextStyle(fontSize: 18.0),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "";
                      }
                    },
                  ),
                ),
              ),
              Row(
                children: <Widget> [
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Visibility(
                        visible: visivel,
                        child:loadingFrete ? LinearProgressIndicator() : Text("Valor Frete: ${valorFrete.toStringAsFixed(2)}", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
