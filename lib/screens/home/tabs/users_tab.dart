import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/users/users_bloc.dart';
import 'package:virtual_store_manager/screens/home/tiles/user_tile.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _userBloc = BlocProvider.of<UsersBloc>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pesquisar',
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(Icons.search, color: Colors.white),
              border: InputBorder.none
            ),
            onChanged: _userBloc.onChangedSearch,
          ),
        ),
        Expanded(
          child: StreamBuilder<List>(
            stream: _userBloc.streamUsers,
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  ),
                );
              }
              else if(snapshot.data.length == 0) {
                return Center(
                  child: Text(
                    'Nenhum usuário encontrado!',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                );
              }

              return ListView.separated(
                  itemBuilder: (context, index) => UserTile(snapshot.data[index]),
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: snapshot.data.length
              );
            }
          ),
        )
      ],
    );
  }
}
