import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

import 'home.dart';

class OrderInfo extends StatefulWidget {
  OrderPed order;

  OrderInfo(this.order);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  final _controller = StreamController<DocumentSnapshot>.broadcast();

  Firestore db = Firestore.instance;
  OrderPed ord;

  Stream<QuerySnapshot> _adicionarListenerRequisicoes(){

    final stream = db.collection("pedidos").document(widget.order.idPedido).snapshots();

    stream.listen((dados){
      _controller.add(dados) ;
    });

  }


  @override
  void initState() {
    super.initState();
    _adicionarListenerRequisicoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              Firestore db = Firestore.instance;

              List<DocumentSnapshot> documentList;
              documentList = (await Firestore.instance
                      .collection("usuarios")
                      .where("id", isEqualTo: widget.order.userClId)
                      .getDocuments())
                  .documents;

              User usuario = User();
              usuario.urlImagem = documentList[0].data["urlImagem"];
              usuario.idUser = documentList[0].data["id"];
              usuario.deliveryman = false;
              usuario.nome = documentList[0].data["nome"];
              usuario.email = documentList[0].data["email"];
              usuario.balance = documentList[0].data["balance"];

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(usuario),
                  ));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("Pedido"),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('pedidos').where("idPedido", isEqualTo: widget.order.idPedido).snapshots(),
                      builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Text("");
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text("Erro ao carregar os dados!");
                    } else {
                      //QuerySnapshot querySnapshot = snapshot.data;
                      if (false) {
                        return Text("");
                      } else {
                        return Container(
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                AppBar(
                                  automaticallyImplyLeading: false,
                                  title: Text("Informações Pedido"),
                                  backgroundColor: Colors.deepPurple,
                                  actions: [
                                    PhysicalModel(
                                      color: Colors.transparent,
                                      child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                            size: 40,
                                          )),
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    PhysicalModel(
                                      color: Colors.transparent,
                                      child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.chat,
                                            size: 40,
                                          )),
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                  ],
                                ),
                                ListTile(
                                  leading: Icon(Icons.list),
                                  title: Text(
                                      "Quantidade de Itens: ${widget.order.itens.length}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.shopping_cart),
                                  title: Text(
                                      "Super Mercado: ${snapshot.data.documents[0]["nomeMarket"]}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on),
                                  title: Text(
                                      "Endereço: ${snapshot.data.documents[0]["ruaDest"]}, ${snapshot.data.documents[0]["numDest"]}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.calendar_today),
                                  title: Text(
                                      "Data: ${formatDate(DateTime.fromMicrosecondsSinceEpoch(widget.order.dataHoraPed.microsecondsSinceEpoch), [
                                        dd,
                                        '/',
                                        mm,
                                        '/',
                                        yyyy
                                      ])}"),
                                ),
                                ListTile(
                                  leading: CircularProgressIndicator(),
                                  title: Text(
                                      "Situação: ${snapshot.data.documents[0]["situacao"]}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text("Entregador: ${snapshot.data.documents[0]["entregadorClId"] != null ? snapshot.data.documents[0]["entregadorClId"] : "Procurando"}"),
                                ),
                                LinearProgressIndicator(
                                  value: 0,
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    }
                }
              }))
            ],
          ),
        ),
      ),
    );
  }
}
