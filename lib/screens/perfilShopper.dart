import 'package:compra_rapida_2/models/shopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';



class perfilShopper extends StatelessWidget {
  Shopper shopper;
  int num;
  var maskFormatter = new MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });

  perfilShopper(this.shopper, this.num);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopper.nome),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              SizedBox(
                height: 10,
              ),
            Center(
              child:  Container(
                  margin: EdgeInsets.zero,
                  height: 200,
                  width: 200,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(shopper.foto),
                  )),
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Flexible(
                      child: Text("Nota: ", style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),),),
                  Container(

                    child: RatingBar.builder(
                    initialRating: shopper.rate,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    ignoreGestures: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),

                  ),),


                ],
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(48, 0, 30, 0),
                child: ListTile(
                  selected: true,
                  onTap: () {
                    launch("tel:${shopper.phone}");
                  },
                  title: Text("Telefone: ${maskFormatter.maskText(shopper.phone)}", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(48, 0, 30, 0),
                child: ListTile(
                  selected: false,
                  onTap: () {

                  },
                  title: Text("Numero de pedidos entregues: ${num}", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                ),
              )












            ],
          ),
        ),
      ),
    );
  }
}
