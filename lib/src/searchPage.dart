import 'package:flutter/material.dart';
import 'package:history_go/src/infoPage.dart';

import 'perm.dart';

class SearchPage extends StatelessWidget {
  final Color color;

  SearchPage(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: FlatButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionPage()));
          },
          child: Text(
            'Kaknästornet',
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),

    );
  }
}
