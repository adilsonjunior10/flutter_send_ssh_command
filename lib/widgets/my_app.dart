import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssh2/ssh2.dart';
import 'snackbar.dart';
import 'dart:io';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isIpOnline = false; // VERIFICA SE HA ALGUM ENDERECO IP ATIVO.
  String _ipFound = ""; // ARMAZENA O ENDERECO DE IP QUE PASSOU NO TESTE DE PING.
  String _result = ''; // ARMAZENA A RESPOSTA RECEBIDA DA SOLICITACAO.

  //LISTA DOS IPS INCLUSOS NA VARREDURA DE REDE
  List _ips = ["192.168.1.1", "192.168.0.1", "192.168.0.254", "192.168.1.254", "10.0.0.1"];

  //CONFIGURACAO DE CONEXAO SSH
  final String username = 'admin'; //USUARIO SSH
  final String password = 'admin'; //SENHA SSH
  final int port = 22; //PORTA DE CONEXAO

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento SSH'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: escanearRede,
                      icon: Icon(Icons.wifi),
                      label: Text("Escanear rede"),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black.withAlpha(150),
                      maxRadius: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        maxRadius: 10,
                        child: CircleAvatar(
                          backgroundColor: _isIpOnline ? Colors.green : Colors.grey,
                          maxRadius: 8,
                        ),
                      ),
                    ),
                    Text("IP Encontrado:\n$_ipFound", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(height: 1, thickness: 2, indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      side: BorderSide(width: 5, color: _isIpOnline ? Colors.white : Colors.grey.withAlpha(150)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _isIpOnline ? fecharConexao : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 60),
                        Text("Fechar", style: TextStyle(fontSize: 18)),
                        Text("Bloquear acesso ao equipamento", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      side: BorderSide(width: 5, color: _isIpOnline ? Colors.white : Colors.grey.withAlpha(150)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _isIpOnline ? abrirConexao : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_open_outlined, size: 60),
                        Text("Abrir", style: TextStyle(fontSize: 18)),
                        Text("Liberar acesso ao equipamento", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(height: 1, thickness: 2, indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26.withAlpha(40),
                    border: Border.all(
                      color: _result.isNotEmpty ? Colors.blueAccent : Colors.grey,
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _result.isNotEmpty
                          ? Text("RESPOSTA DO EQUIPAMENTO:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ))
                          : Text("\nA resposta do comando será retornada aqui:", style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 15),
                      ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(2.0),
                        children: <Widget>[
                          Text(_result),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetValues() => setState(() => _result = "Carregando..."); //RESETA O CAMPO DE TEXTO DE RESPOSTA

  // FUNCAO REALIZA O SCAN DE IPs NA REDE.
  Future<void> escanearRede() async {
    ScaffoldMessenger.of(context).showSnackBar(Snackbar().snackBarIpLoading);
    bool _exitLoop = false;
    for (var ip in _ips) {
      await Socket.connect(ip, 80, timeout: Duration(seconds: 3)).then((socket) {
        setState(() {
          _exitLoop = true;
          _isIpOnline = true;
          _ipFound = ip;
        });
        print("Ping com sucesso no IP: $ip");
        socket.destroy();
      }).catchError((error) {
        print("Exceção no socket ${error.toString()}");
      });
      if (_exitLoop == true) break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_isIpOnline == true)
      ScaffoldMessenger.of(context).showSnackBar(Snackbar().snackBarIpSuccess);
    else {
      ScaffoldMessenger.of(context).showSnackBar(Snackbar().snackBarIpFailed);
      setState(() => _ipFound = "--- Nenhum ---");
    }
  }

  //REALIZA O BLOQUEIO DE ACESSO AO AQUIPAMENTO.
  Future<void> fecharConexao() async {
    String result = '';
    resetValues();

    var client = new SSHClient(
      host: _ipFound,
      port: port,
      username: username,
      passwordOrKey: password,
    );

    try {
      result = await client.connect() ?? 'Nulo';
      print(result);
      if (result == "session_connected") result = await client.execute("ps") ?? 'Nulo';
      await client.disconnect();
    } on PlatformException catch (e) {
      String errorMessage = 'Erro: ${e.code}\nMensagem de erro: ${e.message}';
      result = errorMessage;
      print(errorMessage);
    }

    setState(() => _result = result);
  }

  //REALIZA A LIBERACAO DE ACESSO AO AQUIPAMENTO.
  Future<void> abrirConexao() async {
    String result = '';
    resetValues();

    var client = new SSHClient(
      host: _ipFound,
      port: port,
      username: username,
      passwordOrKey: password,
    );

    try {
      result = await client.connect() ?? 'Nulo';
      if (result == "session_connected") result = await client.execute("ls") ?? 'Nulo';
      await client.disconnect();
    } on PlatformException catch (e) {
      String errorMessage = 'Erro: ${e.code}\nMensagem de erro: ${e.message}';
      result = errorMessage;
      print(errorMessage);
    }

    setState(() => _result = result);
  }
}
