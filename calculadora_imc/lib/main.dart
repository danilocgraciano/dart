import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var weightController = TextEditingController();
  var heightController = TextEditingController();
  var _infoText = 'Informe seus dados';

  var _formKey = GlobalKey<FormState>();

  void _resetFields() {
    weightController.text = '';
    heightController.text = '';
    setState(() {
      _infoText = 'Informe seus dados';
      _formKey = GlobalKey<FormState>();
    });
  }

  void _calculate() {
    setState(() {
      var weight = double.parse(weightController.text);
      var height = double.parse(heightController.text) / 100;
      double imc = weight / (height * height);

      if (imc < 18.6) {
        _infoText = 'Abaixo do peso (${imc.toStringAsPrecision(3)})';
      } else if (imc >= 18.6 && imc < 24.9) {
        _infoText = 'Peso ideal (${imc.toStringAsPrecision(3)})';
      } else if (imc >= 24.9 && imc < 29.9) {
        _infoText = 'Levemente acima do peso (${imc.toStringAsPrecision(3)})';
      } else if (imc >= 29.9 && imc < 34.9) {
        _infoText = 'Obesidade grau I (${imc.toStringAsPrecision(3)})';
      } else if (imc >= 34.9 && imc < 39.9) {
        _infoText = 'Obesidade grau II (${imc.toStringAsPrecision(3)})';
      } else {
        _infoText = 'Obesidade grau III (${imc.toStringAsPrecision(3)})';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
        centerTitle: false,
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _resetFields();
              })
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                getLogo(),
                getFieldPeso(),
                getFieldAltura(),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      child: Text(
                        'Calcular',
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      ),
                      color: Colors.green,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _calculate();
                        }
                      },
                    ),
                  ),
                ),
                getInfoText()
              ],
            ),
          )),
    );
  }

  Widget getLogo() {
    return Icon(
      Icons.person_outline,
      size: 120,
      color: Colors.green,
    );
  }

  Widget getFieldPeso() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: 'Peso (kg)', labelStyle: TextStyle(color: Colors.green)),
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.green, fontSize: 25),
      controller: weightController,
      validator: (value) {
        if (value.isEmpty) return 'Peso inválido';
      },
    );
  }

  Widget getFieldAltura() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: 'Altura (cm)', labelStyle: TextStyle(color: Colors.green)),
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.green, fontSize: 25),
      controller: heightController,
      validator: (value) {
        if (value.isEmpty) return 'Altura inválida';
      },
    );
  }

  Widget getInfoText() {
    return Text(
      _infoText,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.green, fontSize: 25.0),
    );
  }
}
