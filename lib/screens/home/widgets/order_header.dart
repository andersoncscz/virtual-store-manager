import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/users/users_bloc.dart';

class OrderHeader extends StatelessWidget {

  final DocumentSnapshot order;
  OrderHeader({@required this.order});

  @override
  Widget build(BuildContext context) {
    
    final _usersBloc = BlocProvider.of<UsersBloc>(context);
    final _user = _usersBloc.getUser(order.data['user_id']);
    
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${_user['name']}'),
              Text('${_user['email']}', style: TextStyle(fontSize: 13)),
            ],
          )
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('Produtos R\$ ${order['products_price'].toStringAsFixed(2)}'),
            Text('Total R\$ ${order['total_price'].toStringAsFixed(2)}'),
          ],
        )
      ],
    );
  }
}
