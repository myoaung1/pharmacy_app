import 'package:flutter/material.dart';

Widget getMessagePopup(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      FlatButton(
        child: Text(
          'OK',
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
