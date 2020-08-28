import 'package:flutter/material.dart';
import 'package:ojol_driver_app/ui/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Username"),
            TextField(),
            SizedBox(height: 32),
            Text("Password"),
            TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            SizedBox(height: 32),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())),
                elevation: 0,
                color: Colors.blue,
                textColor: Colors.white,
                padding: EdgeInsets.all(16),
                child: Text("Login"),
              )
            )
          ],
        ),
      ),
    );
  }
}