import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=bc27c1bc";

void main() async {
  runApp(MaterialApp(home: Home()));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  double ibovespa;
  double nasdaq;
  double dowjones;
  double nikkei;

  void realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Cotações",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            actions: [
              IconButton(icon: Icon(Icons.refresh), onPressed: refresh)
            ]),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Atualizando informações...",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Houve um erro na sua solicitação...",
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    ibovespa = snapshot.data["results"]["stocks"]["IBOVESPA"]
                        ["points"];
                    nasdaq =
                        snapshot.data["results"]["stocks"]["NASDAQ"]["points"];
                    dowjones = snapshot.data["results"]["stocks"]["DOWJONES"]
                        ["points"];
                    nikkei =
                        snapshot.data["results"]["stocks"]["NIKKEI"]["points"];

                    return SingleChildScrollView(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                                child: Text("Conversor de moedas",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.blueAccent),
                                    textAlign: TextAlign.left),
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0)),
                            buildTextField(
                                "Real", "R\$ ", realController, realChanged),
                            Divider(),
                            buildTextField("Dólar", "US\$ ", dolarController,
                                dolarChanged),
                            Divider(),
                            buildTextField(
                                "Euro", "€ ", euroController, euroChanged),
                            Container(
                                child: Text("Índices",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.blueAccent),
                                    textAlign: TextAlign.left),
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0)),
                            Container(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                  cardBuilder("IBOVESPA", ibovespa),
                                  cardBuilder("NASDAQ", nasdaq),
                                  cardBuilder("DOW JONES", dowjones),
                                  cardBuilder("NIKKEI", nikkei),
                                ]))
                          ],
                        ));
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController t, Function f) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      prefixText: prefix,
    ),
    keyboardType: TextInputType.number,
    style: TextStyle(
      color: Colors.blueAccent,
      fontSize: 20,
    ),
    controller: t,
    onChanged: f, //String modificada é passado ao argumento da função f (text)
  );
}

Widget cardBuilder(String text, double value) {
  return Card(
    child: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Text(text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black)),
            Text(
              value.toStringAsFixed(0) + " pts",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            )
          ],
        )),
  );
}
