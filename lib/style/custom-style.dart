import 'package:flutter/material.dart';

Decoration decoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    boxShadow: [
      BoxShadow(
        color: Colors.grey[500].withOpacity(0.4),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 2), // changes position of shadow
      ),
    ],
  );
}
