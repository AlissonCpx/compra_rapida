import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/screens/minhaLista.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class Historico extends StatefulWidget {
  String idUser;


  Historico(this.idUser);

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Histórico de Pedidos"),
          centerTitle: true,
        ),
        body: Container(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('pedidos')
                    .where("userClId.id", isEqualTo: widget.idUser)
                    .orderBy("dataHoraPed")
                    .snapshots(),
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
                          List<DocumentSnapshot> documents =
                          snapshot.data.documents.toList();

                          return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              height: 260,
                              child: Card(
                                  child: GestureDetector(
                                    onTap: () async {
                                      OrderPed ped = await Util.pesquisaOrder(documents[index]["idPedido"]);

                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MinhaLista(ped, documents[index].documentID ),));
                                    },
                                    child: Column(
                                      children: <Widget> [
                                        ListTile(
                                          leading: Icon(Icons.list),
                                          title: Text("Situação: ${documents[index].data['situacao']}"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.shopping_cart),
                                          title: Text("Super Mercado: ${documents[index].data['mercado']['nome']}"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.calendar_today),
                                          title: Text("Data: ${formatDate(DateTime.fromMicrosecondsSinceEpoch(documents[index].data['dataHoraPed'].microsecondsSinceEpoch), [dd, '/', mm, '/', yyyy])}"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.monetization_on),
                                          title: Text("Valor: ${documents[index].data['valorFrete'].toStringAsFixed(2)}"),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    ),
                                  )
                              ),
                            );
                          });
                        }
                      }
                  }
                })));
  }
}
