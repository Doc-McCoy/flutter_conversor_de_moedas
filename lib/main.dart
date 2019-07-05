import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; // Lib de conversão do json
import 'package:http/http.dart' as http; // Lib que faz requisições http
/* Para usar a lib http, eu precisei antes adicioná-la ao pubspec.yaml,
adicionando na parte de 'dependencies' desta forma:
http: ^0.12.0+2 */

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=a8abfdd2";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

// Função que busca as informações de conversão na API
// O <Map> significa que ela retorna um Map.
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Controllers dos inputs
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  // Variáveis que irão receber os valores de conversão
  double dolar;
  double euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold( // Widget base do materialTheme

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: FutureBuilder<Map>(
          // FutureBuilder é o widget que permite esperar uma função futor retornar para exibir algo
          // FutureBuilder<map>, pois a função que criamos retorna um Map

          future: getData(), // Aqui indico de onde os dados virão

          builder: (context, snapshot) { // Define como a tela vai se comportar durante a busca de dados.

            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                // Enquanto carrega, exibir isso
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );

              default:
                // Ao carregar, verificar se deu erro
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados.",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );

                } else { // Se não deu erro, salva valores e carrega a tela:

                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView( // Widget que permite rolar a tela
                    padding: EdgeInsets.all(10.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[

                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber
                        ),

                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(), // Esse treco cria um espaço entre um widget e outro

                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(), // Esse treco cria um espaço entre um widget e outro

                        buildTextField("Euros", "£", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

// Função que cria os inputs do aplicativo, para evitar repetição de código.
Widget buildTextField(String label, String prefix, TextEditingController controller, Function change) {

  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      // prefixText: prefix, // Retirei o prefix pq tava feio
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: change, // Função chamada quando o input é alterado
    keyboardType: TextInputType.numberWithOptions(decimal: true), // Definir o teclado para numérico
  );
}
