import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Board',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Crypto Board'),
        ),
        body: Content(),
      ),
    ),
  );
}

class Content extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContentState();
}

class ContentState extends State<Content> {
  Future<http.Response> _response;

  @override
  void initState() {
    super.initState();
    setState(() {
      _response =
          http.get("https://api.coinmarketcap.com/v2/ticker/?limit=100");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
            future: _response,
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> response) {
              if (!response.hasData) {
                return Text("Loading...");
              } else if (response.data.statusCode != 200) {
                return Text("Could not connect to service.");
              } else {
                Map<String, dynamic> json = JSON.decode(response.data.body);
                return CryptoBoard(json['data']);
              }
            }));
  }
}

class CryptoBoard extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<ListTile> tiles = [];

  CryptoBoard(this.data) {
    data.forEach(iterateData);
  }

  void iterateData(id, currency) {
    String symbol = currency['symbol'];
    String name = currency['name'];
    String price = currency['quotes']['USD']['price'].toString();
    double change24h = currency['quotes']['USD']['percent_change_24h'];
    Color change24hColor = change24h > 0 ? Colors.green : Colors.red;

    tiles.add(ListTile(
      leading: CryptoIcon(symbol),
      title: SymbolText(symbol),
      subtitle: NameText(name),
      trailing: Column(
        children: <Widget>[
          PriceText(price),
          Change24hText(change24h, change24hColor),
        ],
        crossAxisAlignment: CrossAxisAlignment.end,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: tiles);
  }
}

class CryptoIcon extends StatelessWidget {
  final String symbol;

  CryptoIcon(this.symbol);

  @override
  Widget build(BuildContext context) {
    var asset = AssetImage("assets/icons/${symbol.toLowerCase()}.png");
    Image icon = Image(image: asset, width: 48.0, height: 48.0);
    return Container(child: icon);
  }
}

class SymbolText extends Text {
  SymbolText(String symbol)
      : super(
          symbol,
          style: TextStyle(fontSize: 16.0),
        );
}

class NameText extends Text {
  NameText(String name)
      : super(
          name,
          style: TextStyle(fontSize: 13.0),
        );
}

class PriceText extends Text {
  PriceText(String price)
      : super(
          "\$ $price",
          style: TextStyle(fontSize: 15.0),
        );
}

class Change24hText extends Text {
  Change24hText(double change24h, Color color)
      : super(
          "${change24h.toString()}%",
          style: TextStyle(fontSize: 14.0, color: color),
        );
}
