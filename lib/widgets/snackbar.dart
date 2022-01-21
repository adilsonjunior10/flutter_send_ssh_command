import 'package:flutter/material.dart';

class Snackbar {
  final snackBarIpSuccess = SnackBar(
    content: Row(
      children: [
        Icon(Icons.check, color: Colors.white, size: 40),
        SizedBox(width: 10),
        Text("IP de Gateway encontrado!"),
      ],
    ),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 3),
  );

  final snackBarIpFailed = SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white, size: 40),
        SizedBox(width: 10),
        Text("Nenhum IP de Gateway encontrado!"),
      ],
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 3),
  );

  final snackBarIpLoading = SnackBar(
    content: Row(
      children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Buscando...")],
    ),
    backgroundColor: Colors.blue,
  );
}
