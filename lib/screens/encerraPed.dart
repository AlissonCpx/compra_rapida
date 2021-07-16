import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/shopper.dart';
import 'package:compra_rapida_2/models/status.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/home.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class EncerraPed extends StatefulWidget {
  String idShopper;
  String idUser;

  EncerraPed(this.idShopper, this.idUser);

  @override
  _EncerraPedState createState() => _EncerraPedState();
}

class _EncerraPedState extends State<EncerraPed> {
  Shopper shop;
  double rate;

  void iniciaScreen() async {
    Shopper s = await Util.pesquisaShopper(widget.idShopper);
    setState(() {
      shop = s;
    });
  }

  @override
  void initState() {
    super.initState();
    iniciaScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Icon(
                Icons.check_circle,
                size: 300,
                color: Colors.greenAccent,
              ),
            ),
            Center(
              child: Text(
                "Entrega realizada com sucesso!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
                child: Card(
              elevation: 10,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text(
                      "Avalie o entregador!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        rate = rating;
                      });
                    },
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            )),
            SizedBox(
              height: 15,
            ),
            Container(
                width: 300,
                height: 50,
                child: PhysicalModel(
                  color: Colors.transparent,
                  shadowColor: Colors.black,
                  elevation: 8.0,
                  child: RaisedButton(
                    child: Text(
                      'Voltar',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    textColor: Colors.white,
                    color: Colors.greenAccent,
                    onPressed: () async {

                      Firestore db = Firestore.instance;
                      db
                          .collection("shoppers")
                          .document(widget.idShopper)
                          .updateData({"rate": rate});

                      User user = await Util.getUsuario(widget.idUser);

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(user),
                          ));

                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
