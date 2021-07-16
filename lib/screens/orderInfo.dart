import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/models/shopper.dart';
import 'package:compra_rapida_2/models/status.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/chat_screen.dart';
import 'package:compra_rapida_2/screens/encerraPed.dart';
import 'package:compra_rapida_2/screens/imageNota.dart';
import 'package:compra_rapida_2/screens/perfilShopper.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'home.dart';

class OrderInfo extends StatefulWidget {
  OrderPed order;
  String idDocument;

  OrderInfo(this.order, this.idDocument);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  final _controller = StreamController<DocumentSnapshot>.broadcast();

  Firestore db = Firestore.instance;
  OrderPed ord;





  @override
  void initState() {
    super.initState();
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
                      .where("id", isEqualTo: widget.order.userClId.idUser)
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
                                          onPressed: () async {
                                            OrderPed ped = await Util.pesquisaOrder(widget.order.idPedido);

                                            if (ped.situacao == Status.AGUARDANDO) {
                                              Alert(
                                                  context: context,
                                                  title: "Cancelar Pedido?",
                                                  desc:
                                                  "Deseja prosseguir para cancelar o pedido?",
                                                  buttons: [
                                                    DialogButton(
                                                        child: Text("Sim"),
                                                        onPressed: () async {
                                                          Firestore.instance.collection("pedidos").document(widget.idDocument).delete();
                                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(widget.order.userClId),));
                                                        }),
                                                    DialogButton(
                                                        child: Text("Não"),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        }),
                                                  ]).show();
                                            } else {
                                              Alert(
                                                buttons: [],
                                                  context: context,
                                                  title: "Pedido em andamento",
                                                  desc:
                                                  "Não é possivel cancelar um pedido em andamento!",
                                                  ).show();
                                            }
                                          },
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
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatScreen(widget.order.userClId.idUser, widget.idDocument),
                                                ));
                                          },
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
                                      "Super Mercado: ${snapshot.data.documents[0]["mercado"]["nome"]}"),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on),
                                  title: Text(
                                      "Endereço: ${snapshot.data.documents[0]["destino"]["rua"]}, ${snapshot.data.documents[0]["destino"]["numero"]}"),
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
                                  onTap: snapshot.data.documents[0]["valorNota"] != null ? () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImageNota(snapshot.data.documents[0]["nota"]),));
                                  } : null,
                                  leading: Icon(Icons.attach_money),
                                  selected: snapshot.data.documents[0]["valorNota"] != null,
                                  title: Text(
                                      "Valor:\n \nEntrega: ${widget.order.valorFrete.toStringAsFixed(2)} \nNota: "
                                          "${snapshot.data.documents[0]["valorNota"] != null ? snapshot.data.documents[0]["valorNota"].toStringAsFixed(2) : ""}"
                                          ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.adjust),
                                  title: Text(
                                      "Situação: ${snapshot.data.documents[0]["situacao"]}"),
                                ),
                                ListTile(
                                  onTap: snapshot.data.documents[0]["entregadorClId"] != null ? () async {
                                    Shopper s = await Util.pesquisaShopper(snapshot.data.documents[0]["entregadorClId"]["id"]);

                                    List<DocumentSnapshot> documentList;
                                    documentList = (await Firestore.instance
                                        .collection("pedidos")
                                        .where("entregadorClId.id", isEqualTo: s.idUser)
                                        .getDocuments())
                                        .documents;

                                    Navigator.push(context, MaterialPageRoute(builder: (context) => perfilShopper(s, documentList.length),));

                                  } : null,
                                  leading: Icon(Icons.person),
                                  selected: snapshot.data.documents[0]["entregadorClId"] != null,
                                  title: Text("Entregador: ${snapshot.data.documents[0]["entregadorClId"] != null ? snapshot.data.documents[0]["entregadorClId"]["nome"] : "Procurando"}"),
                                ),
                                LinearProgressIndicator(
                                  value: 0,
                                ),
                                SizedBox(
                                  height: 30,
                                ),

                                Visibility(
                                  visible: snapshot.data.documents[0]["situacao"] == Status.CONFIRMADA,
                                    child: Container(
                                        width: 300,
                                        height: 50,
                                        child: PhysicalModel(
                                          color: Colors.transparent,
                                          shadowColor: Colors.black,
                                          elevation: 8.0,
                                          child: RaisedButton(
                                            child: Text(
                                              'Confirmar Entrega',
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                            textColor: Colors.white,
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              Alert(
                                                  context: context,
                                                  title: "Confirmar Entrega?",
                                                  desc:
                                                  "Confira todos os produtos antes de confirmar!",
                                                  buttons: [
                                                    DialogButton(
                                                        child: Text("Sim"),
                                                        onPressed: () async {
                                                          Firestore db = Firestore.instance;
                                                          db
                                                              .collection("pedidos")
                                                              .document(widget.idDocument)
                                                              .updateData({"situacao": Status.ENTREGUE});

                                                          double vNota = snapshot.data.documents[0]["valorNota"];
                                                          double vFrete = snapshot.data.documents[0]["valorFrete"];
                                                          double vPorc = vFrete / 0.3;
                                                          double totalFrete = vFrete - vPorc;

                                                          db
                                                              .collection("shoppers")
                                                              .document(widget.idDocument)
                                                              .updateData({"balance": (vNota + totalFrete)});

                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => EncerraPed(snapshot.data.documents[0]["entregadorClId"]["id"], snapshot.data.documents[0]["userClId"]["id"]),
                                                              ));
                                                          
                                                        }),
                                                    DialogButton(
                                                        child: Text("Não"),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        }),
                                                  ]).show();
                                            },
                                          ),
                                        )),


                                ),
                                SizedBox(
                                  height: 50,
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
