import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    BuildContext context, String title, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<String> showInputDialog(
    BuildContext context, String prompt, bool inputRequired) {
  TextEditingController customController = TextEditingController();

  var input = inputRequired ? TextField(controller: customController) : null;

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(prompt),
          content: input,
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            MaterialButton(
              elevation: 5.0,
              child: Text('GO!'),
              onPressed: () {
                Navigator.of(context).pop(
                  inputRequired ? customController.text.toString() :
                  'GO!');
              },
            ),
          ],
        );
      });
}
