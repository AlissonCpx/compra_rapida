import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/newList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {

  User user;


  Home(this.user);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {




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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewList(widget.user),));
        },
      ),
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white70,
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
                      Text('${widget.user.nome}', maxLines: 1, style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),),
                      FlatButton(
                          onPressed: () {},
                          child: PhysicalModel(
                              color: Colors.transparent,
                          child: Text("Sair", style: TextStyle(
                            color: Colors.blueGrey
                          ),),
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
                    Icons.home,
                    color: Colors.black,
                    size: 40,
                  ),
                  title: Text(
                    "Home",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {},
                  selected: true,
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
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  autocorrect: true,
                  autofocus: false,
                  controller: null,
                  decoration: InputDecoration(
                      hintText: 'Pesquisar Mercados',
                      prefixIcon: Icon(Icons.search),
                      labelStyle: TextStyle(color: Colors.redAccent)),
                  style: TextStyle(fontSize: 18.0),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Insira o email";
                    }
                  },
                ),
              ),

              SizedBox(
                height: 30,
              ),
              Text('Ultimas listas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





















