import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/models/pedido.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/newList.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'orderInfo.dart';

class Home extends StatefulWidget {
  User user = User();

  Home(this.user);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Pedido> pedidos = [];
  OrderPed ordersInfos = new OrderPed();
  bool loadingOrder = false;
  bool loadingListas = false;
  bool possuiOrder = false;
  bool possuiLista = false;

  Widget trocaFoto() {
    if (widget.user.urlImagem != null) {
      return Container(
          margin: EdgeInsets.zero,
          height: 140,
          width: 140,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.user.urlImagem),
          ));
    } else {
      return Container(
          margin: EdgeInsets.zero,
          height: 130,
          width: double.infinity,
          child: CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.person,
              color: Colors.black,
              size: 100,
            ),
          ));
    }
  }

  _trazUltimasListas() async {
    Firestore db = Firestore.instance;

    List<DocumentSnapshot> documentList;
    documentList = (await db
            .collection("usuarios")
            .document(widget.user.idUser)
            .collection("pedidos")
            .getDocuments())
        .documents;

    if (documentList.isNotEmpty) {
      for (int i = documentList.length - 1; i >= documentList.length - 3; i--) {
        Pedido ped = new Pedido();
        ped.situacao = "nada";
        ped.userId = documentList[i]["id"];
        ped.itens = documentList[i]["itens"];
        setState(() {
          possuiLista = true;
          pedidos.add(ped);
        });
      }
    }
  }

  _trazUltimoPedido() async {
    Firestore db = Firestore.instance;
    setState(() {
      loadingOrder = true;
    });

    List<DocumentSnapshot> documentList;
    documentList = (await db
            .collection("pedidos")
            .where("userClId.id", isEqualTo: widget.user.idUser)
            .getDocuments())
        .documents;

    if (documentList.isNotEmpty) {
      int ultimoPed = documentList.length - 1;
      ordersInfos.dataHoraPed = documentList[ultimoPed].data["dataHoraPed"];
      ordersInfos.itens = documentList[ultimoPed].data["itens"];
      ordersInfos.situacao = documentList[ultimoPed].data["situacao"];
      ordersInfos.ruaDest = documentList[ultimoPed].data["ruaDest"];
      ordersInfos.nomeMarket = documentList[ultimoPed].data["nomeMarket"];
      ordersInfos.numDest = documentList[ultimoPed].data["numDest"];
      ordersInfos.entregadorClId = documentList[ultimoPed].data["entregadorClId"];
      User user = await Util.getUsuario(documentList[ultimoPed].data["userClId"]["id"]);
      ordersInfos.userClId = user;
      ordersInfos.longitudeMarketDest =
          documentList[ultimoPed].data["longitudeMarketDest"];
      ordersInfos.latitudeMarketDest =
          documentList[ultimoPed].data["latitudeMarketDest"];
      ordersInfos.numMarketDest = documentList[ultimoPed].data["numMarketDest"];
      ordersInfos.longitudeDest = documentList[ultimoPed].data["longitudeDest"];
      ordersInfos.latitudeDest = documentList[ultimoPed].data["latitudeDest"];
      ordersInfos.dataEntregaPed = documentList[ultimoPed].data["dataEntregaPed"];
      ordersInfos.idPedido = documentList[ultimoPed].data["idPedido"];
      setState(() {
        possuiOrder = true;
      });
    }

    setState(() {
      loadingOrder = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _trazUltimasListas();
    _trazUltimoPedido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          List nada = [];
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewList(widget.user, nada, true),
              ));
        },
      ),
      appBar: AppBar(
        title: Text(
          'Compra Rápida',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
          child: Container(
        color: Colors.white70,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.lightBlueAccent,
              width: 300,
              child: Column(
                children: [
                  trocaFoto(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${widget.user.nome}',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  FlatButton(
                      onPressed: () {},
                      child: PhysicalModel(
                        color: Colors.transparent,
                        child: Text(
                          "Sair",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        elevation: 12,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.chat,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Mensagens",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.monetization_on,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Pagamento",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.list,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Minhas Listas",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.phone,
                size: 40,
                color: Colors.black,
              ),
              title: Text(
                "Contato",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
          ],
        ),
      )),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 300,
                  width: 600,
                  child: Center(
                    child: Card(
                      elevation: 10,
                      child: Column(
                        children: <Widget>[
                          PhysicalModel(
                            child: Container(
                              child: AppBar(
                                automaticallyImplyLeading: false,
                                title: Text("Ultimas Listas:"),
                                backgroundColor: Colors.deepPurple,
                                elevation: 20,
                              ),
                              color: Colors.deepPurple,
                            ),
                            color: Colors.transparent,
                            elevation: 10,
                          ),

                          possuiLista ?
                          Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pedidos.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewList(
                                                  widget.user,
                                                  pedidos[index].itens,
                                                  false),
                                            ));
                                      },
                                      child: Container(
                                        width: 200,
                                        height: 100,
                                        child: Card(
                                          color: Colors.lightBlueAccent,
                                          child: ListView.builder(
                                              itemCount:
                                                  pedidos[index].itens.length,
                                              itemBuilder: (context, index2) {
                                                return ListTile(
                                                  leading: Icon(Icons.list),
                                                  title: Text(pedidos[index]
                                                      .itens[index2]["Item"]),
                                                  subtitle: Text(pedidos[index]
                                                          .itens[index2]
                                                      ["comment"]),
                                                );
                                              }),
                                        ),
                                      ),
                                    );
                                  })) : Container(
                            width: 200,
                            height: 200,
                            alignment: Alignment.center,
                            child: Center(
                              child: Text("Voce ainda não possui Listas..."),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              Container(
                height: 300,
                width: 400,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text("Ultimo Pedido:"),
                        backgroundColor: Colors.deepPurple,
                        elevation: 20,
                      ),
                      loadingOrder ? Padding(
                          padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                      ) : (possuiOrder != false ?
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderInfo(ordersInfos),
                                    ));
                              },
                              child: Card(
                                  child: Column(
                                    children: <Widget> [
                                      ListTile(
                                        leading: Icon(Icons.list),
                                        title: Text("Quantidade de Itens: ${ordersInfos.itens.length}"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.shopping_cart),
                                        title: Text("Super Mercado: ${ordersInfos.nomeMarket}"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.calendar_today),
                                        title: Text("Data: ${formatDate(DateTime.fromMicrosecondsSinceEpoch(ordersInfos.dataHoraPed.microsecondsSinceEpoch), [dd, '/', mm, '/', yyyy])}"),
                                      ),
                                      Text("Ver mais...", style: TextStyle(
                                          color: Colors.lightBlueAccent
                                      ),),
                                      SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  )
                              ),
                            )
                          ) :
                      Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: Center(
                          child: Text("Voce ainda não possui pedido..."),
                        ),
                      ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
