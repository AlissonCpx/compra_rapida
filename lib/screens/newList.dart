import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/pedido.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';

class NewList extends StatefulWidget {
  @override
  _NewListState createState() => _NewListState();

  User user;

  NewList(this.user);
}

class _NewListState extends State<NewList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formkey = GlobalKey<FormState>();

  final itemController = TextEditingController();
  final commentController = TextEditingController();
  List itemList = [];

  void _addItem() {
    setState(() {
      Map<String, dynamic> newItem = Map();
      newItem["Item"] = itemController.text;
      newItem["comment"] = "";
      itemController.clear();
      itemList.add(newItem);
    });
  }

  void _settingModalBottomSheet(context, int index) {
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
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              "Digite um comentario:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.edit),
                              labelText: "Comentário",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                            ),
                            onChanged: (value) {
                              setState(() {
                                Map<String, dynamic> commentItem = Map();
                                commentItem["Item"] = itemList[index]["Item"];
                                commentItem["comment"] = value;
                                itemList.removeAt(index);
                                itemList.insert(index, commentItem);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          );
        });
  }

  Widget buildItemList(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        leading: Icon(Icons.format_list_bulleted),
        trailing: IconButton(
            icon: Icon(Icons.add_comment),
            onPressed: () {
              commentController.text = itemList[index]["comment"];
              _settingModalBottomSheet(context, index);
            }),
        title: Text(itemList[index]["Item"]),
        subtitle: Text(itemList[index]["comment"]),
      ),
      onDismissed: (direction) {
        setState(() {
          Map<String, dynamic> lastRemoved = Map.from(itemList[index]);
          int lastRemovedPos = index;
          itemList.removeAt(index);
          final snack = SnackBar(
            content: Text("Item \"${lastRemoved["Item"]}\" removido"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    itemList.insert(lastRemovedPos, lastRemoved);
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.save,
            size: 40,
          ),
          onPressed: () {

            Pedido ped = new Pedido();
            ped.userId = widget.user.idUser;
            ped.situacao = "avalia";
            ped.itens = itemList;

            Firestore db = Firestore.instance;
            db.collection("usuarios").document(widget.user.idUser).collection("pedidos").document().setData(ped.toMap());

            Alert(
                context: context,
                title: "Lista de Compras Salva!",
                desc:
                "Deseja prosseguir para o pedido?",
                buttons: [
                  DialogButton(
                      child: Text("Sim"),
                      onPressed: () {

                      }),
                  DialogButton(
                      child: Text("Não"),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }),
                ]).show();

          }),
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () {
            String mensagem = "*Lista de Compras*\n";
            for ( int i = 0; i < itemList.length; i++ ){
              mensagem += "${i+1}. ${itemList[i]["Item"]} \n";
            }
            Share.share(mensagem);
          }),
        ],
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text("Nova Lista"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Form(
              key: formkey,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        if (formkey.currentState.validate()) {
                          _addItem();
                        }
                      },
                      controller: itemController,
                      maxLength: 40,
                      decoration: InputDecoration(
                          labelText: "Item:",
                          hoverColor: Colors.red,
                          prefixIcon: Icon(Icons.shopping_cart)),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Digite um item para a lista!";
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  CircleAvatar(
                    child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            _addItem();
                          }
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            itemList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: itemList.length,
                      itemBuilder: buildItemList,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
