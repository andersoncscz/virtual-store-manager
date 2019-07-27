import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UsersBloc extends BlocBase {

  final _usersController = BehaviorSubject<List>();

  /*
  Cria uma mapa para os usuários, exemplo:
  Map {
    'asmdlasMDKASkdAJSHGdP9102839012ads': Map {
      'uid': asmdlasMDKASkdAJSHGdP9102839012ads,
      'name': 'Anderson'
    },
    ...
  }
   */
  Map<String, Map<String, dynamic>> _users = {};

  Stream<List> get streamUsers => _usersController.stream;

  Firestore _firestore = Firestore.instance;

  UsersBloc() {
    _addClientsListeners();
  }

  
  void _addClientsListeners() {
    //Fica monitorando apenas alterações na collections 'users'. Não retorna toda coleção, apenas quem sofreu alterações
    _firestore.collection('users').snapshots().listen((snapshot) {
      snapshot.documentChanges.forEach((change) {

        String uid = change.document.documentID;
        //Verifica os tipos de mudanças: added, modified, removed.
        switch(change.type) {
          case DocumentChangeType.added:

            _users[uid] = change.document.data; //Adiciona no mapa.
            _subscribeToOrders(uid); //Se inscreve para receber notificações

            break;
          case DocumentChangeType.modified:

            _users[uid].addAll(change.document.data); //Adiciona todos os dados, não só os modificados.
            _usersController.add(_users.values.toList()); //Envia os usuários do map _users pela stream, caso ele tenha seus dados alterados.

            break;
          case DocumentChangeType.removed:

            _users.remove(uid); //Remove do mapa.
            _unsubscribeToOrders(uid); //Se desinscreve para receber notificações
            _usersController.add(_users.values.toList()); //Envia os usuários do map _users pela stream, caso algum tenha sido excluido.

            break;
        }

      });
    });
  }

  void _subscribeToOrders(String uid) {
    _users[uid]['subscription'] = _firestore.collection('users').document(uid).collection('orders').snapshots().listen((orders) async {

        int totalOrders = orders.documents.length; //Total de pedidos
        double money = 0.0; //Total de gastos

        for(DocumentSnapshot doc in orders.documents) { //Percorre os pedidos
          DocumentSnapshot order = await _firestore.collection('orders').document(doc.documentID).get(); //Pega os dados de todos os pedidos na collection 'orders'
          if (order.data['total_price'] == null) continue; //Valida se o pedido da lista existe, pois ele pode estar na lista, mas o usuário ter deletado.

          money += order.data['total_price']; //Soma o total do usuário.
        }
        
        //Adiciona no mapa.
        _users[uid].addAll({
          'total_money': money,
          'total_orders': totalOrders
        });

        _usersController.add(_users.values.toList()); //Envia todos usuários do map _users pela stream.
    });
  }

  void _unsubscribeToOrders(String uid) {
    _users[uid]['subscription'].cancel();
  }

  void onChangedSearch(String search) {
    if (search.trim().isEmpty) {
      _usersController.add(_users.values.toList());
    }
    else {
      _usersController.add(_filter(search.trim()));
    }
  }

  Map<String, dynamic> getUser(String uid) {
    return _users[uid];
  }

  List<Map<String, dynamic>> _filter(String search) {
    List<Map<String, dynamic>> filteredUsers = List.from(_users.values.toList());
    filteredUsers.retainWhere((user) {
      //Filtra os usuários pelo nome
      return user['name'].toUpperCase().contains(search.toUpperCase());
    });

    return filteredUsers;

  }

  @override
  void dispose() {
    _usersController.close();
  }

}