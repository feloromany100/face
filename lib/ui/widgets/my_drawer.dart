import 'package:face_recognition/ui/pages/Auth/login_page.dart';
import 'package:face_recognition/ui/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_services.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
           DrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade400,),
            padding: const EdgeInsets.all(10),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/unknown.png"),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Text(
                      "فيلوباتير روماني سعدالله بخيت الجندي",
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              title: const Text(
                "Dashboard",
                style: TextStyle(fontSize: 19),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              )),
          ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              title: const Text(
                "Settings",
                style: TextStyle(fontSize: 19),
              ),
              onTap: () {}
          ),
          ListTile(
              leading: const Icon(
                Icons.login_outlined,
                color: Colors.black,
              ),
              title: const Text(
                "Log out",
                style: TextStyle(fontSize: 19),
              ),
              onTap: () async{
                await AuthService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
          ),
        ],
      ),
    );
  }
}
