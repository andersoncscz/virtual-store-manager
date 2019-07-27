import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserTile extends StatelessWidget {

  final Map<String, dynamic> user;
  UserTile(this.user);

  @override
  Widget build(BuildContext context) {

    final textStyle = TextStyle(color: Colors.white);

    Widget _renderShimmers() {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    height: 20,
                    child: Shimmer.fromColors(
                        child: Container(
                          color: Colors.white.withAlpha(50),
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 20,
                    child: Shimmer.fromColors(
                        child: Container(
                          color: Colors.white.withAlpha(50),
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 50,
                    height: 20,
                    child: Shimmer.fromColors(
                        child: Container(
                          color: Colors.white.withAlpha(50),
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 20,
                    child: Shimmer.fromColors(
                        child: Container(
                          color: Colors.white.withAlpha(50),
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey
                    ),
                  )
                ],
              ),
            ],
          )
      );
    }

    return user.containsKey('total_money')
        ? ListTile(
            title: Text(user['name'], style: textStyle,),
            subtitle: Text(user['email'], style: textStyle),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('Pedidos: ${user['total_orders']}', style: textStyle),
                Text('Total: R\$ ${user['total_money'].toStringAsFixed(2)}', style: textStyle),
              ],
            ),
          )
    : _renderShimmers();
  }
}
