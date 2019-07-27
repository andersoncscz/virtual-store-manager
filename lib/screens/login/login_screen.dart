import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/login/login_bloc.dart';
import 'package:virtual_store_manager/screens/home/home_screen.dart';

import 'widgets/input_field.dart';





class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final _loginBloc = LoginBloc();
  
  @override
  void initState() {
    super.initState();
    _loginBloc.streamLoginState.listen((state) {
      switch(state) {
        case LoginState.SUCCESS:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          break;
        case LoginState.FAILED:
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erro'),
              content: Text('Você não possui os previlégios necessários'),
            )
          );
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<LoginState>(
          initialData: LoginState.LOADING,
          stream: _loginBloc.streamLoginState,
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.data == LoginState.LOADING || snapshot.data == LoginState.SUCCESS) {
              return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)),
              );
            }
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(), //Apenas para centralizar o conteudo da Stack na tela
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(16),
                          child: Icon(
                              Icons.store_mall_directory,
                              color: Theme.of(context).primaryColor,
                              size: 160
                          ),
                        ),
                        InputField(
                          icon: Icons.person_outline,
                          hint: 'E-mail',
                          obscure: false,
                          stream: _loginBloc.streamEmail,
                          onChanged: _loginBloc.changeEmail,
                        ),
                        InputField(
                          icon: Icons.lock_outline,
                          hint: 'Senha',
                          obscure: true,
                          stream: _loginBloc.streamPassword,
                          onChanged: _loginBloc.changePassword,
                        ),
                        SizedBox(height: 32),
                        StreamBuilder<bool>(
                            stream: _loginBloc.streamSubmit,
                            builder: (context, snapshot) {
                              return SizedBox(
                                height: 48,
                                child: RaisedButton(
                                  disabledColor: Colors.white.withAlpha(100),
                                  color: Theme.of(context).primaryColor,
                                  child: Text('ENTRAR'),
                                  textColor: Colors.white,
                                  onPressed: snapshot.hasData ? _loginBloc.submit : null,
                                ),
                              );
                            }
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}
