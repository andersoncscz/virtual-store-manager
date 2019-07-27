import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:virtual_store_manager/blocs/orders/orders_bloc.dart';
import 'package:virtual_store_manager/blocs/users/users_bloc.dart';

import 'tabs/orders_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/users_tab.dart';

import 'widgets/edit_product_category_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentPage = 0;
  PageController _pageController;

  UsersBloc _usersBloc;
  OrdersBloc _ordersBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _usersBloc = UsersBloc();
    _ordersBloc = OrdersBloc();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usersBloc.dispose();
    _ordersBloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: TextStyle(color: Colors.white70)
          )
        ),
        child: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (pageTapped) {
            _pageController.animateToPage(
                pageTapped,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Clientes')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                title: Text('Pedidos')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.list),
                title: Text('Produtos')
            ),
          ]
        ),
      ),
      body: SafeArea(
        child: BlocProvider<UsersBloc>(
          bloc: _usersBloc,
          child: BlocProvider<OrdersBloc>(
            bloc: _ordersBloc,
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                UsersTab(),
                OrdersTab(),
                ProductsTab(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    switch (_currentPage) {
      case 0:
        return null;
        break;
      case 1:
        return SpeedDial(
          child: Icon(Icons.sort),
          backgroundColor: Theme.of(context).primaryColor,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
                child: Icon(Icons.arrow_downward, color: Theme.of(context).primaryColor),
                backgroundColor: Colors.white,
                label: 'Entregues abaixo',
                labelStyle: TextStyle(fontSize: 14),
                onTap: () {
                  _ordersBloc.setOrderCriteria(SortCriteria.FINISHED_LAST);
                }
            ),
            SpeedDialChild(
              child: Icon(Icons.arrow_upward, color: Theme.of(context).primaryColor),
              backgroundColor: Colors.white,
              label: 'Entregues acima',
              labelStyle: TextStyle(fontSize: 14),
              onTap: () {
                _ordersBloc.setOrderCriteria(SortCriteria.FINISHED_FIRST);
              }
            ),
          ],
        );
        break;
      case 2:
        return FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            bool success = await showDialog(
              context: context,
              builder: (context) => EditProductCategoryDialog(),
            );
            
            _scaffoldKey.currentState.removeCurrentSnackBar();

            if (success != null) {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Text(success ? 'Salvo com sucesso' : 'Erro ao salvar.', style: TextStyle(color: Colors.white)),
                )
              );
            }

          },
        );
        break;
    }
    return null;
  }

}
