import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:virtual_store_manager/validators/login_validators.dart';

enum LoginState {
  IDLE,
  LOADING,
  SUCCESS,
  FAILED
}

class LoginBloc extends BlocBase with LoginValidators {

  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  StreamSubscription _streamSubscription;

  LoginBloc() {

    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if (user != null) {
        if (await verifyPrivileges(user)) {
          _stateController.add(LoginState.SUCCESS);
        }
        else {
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.FAILED);
        }
      }
      else {
        _stateController.add(LoginState.IDLE);
      }
    });
  }


  //Streams => saídas do BLOC
  Stream<String> get streamEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get streamPassword => _passwordController.stream.transform(validatePassword);

  //Combina 2 streams para gerar uma unica stream de saída, neste caso uma que gera saídas do tipo bool.
  //Recebe as 2 streams a serem combinadas e uma função de callback que recebe os outputs dessas streams, (a, b).
  //Se os outputs (a, b) dessas streams possuem dado, então elas passaram pelo StreamTransform e foram validadas, então essa combinação retornará true.
  Stream<bool> get streamSubmit => Observable.combineLatest2(
      streamEmail,
      streamPassword,
      (a, b) =>  true
  );

  Stream<LoginState> get streamLoginState => _stateController.stream;



  //Tudo que for enviado a essas funcoes, será repassado automaticamente para o sink.add do StreamController delas.
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;


  void submit() {
    final email = _emailController.value;
    final password = _passwordController.value;

    _stateController.add(LoginState.LOADING);

    FirebaseAuth.instance
      .signInWithEmailAndPassword(
        email: email,
        password: password
    ).catchError((onError) {
      _stateController.add(LoginState.FAILED);
    });
  }


  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance
      .collection('admins')
      .document(user.uid)
      .get()
      .then((doc) {
        if (doc.data != null) {
          return true;
        }
        return false;
    }).catchError((error) {
      return false;
    });
  }



  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _stateController.close();

    _streamSubscription.cancel();
  }

}