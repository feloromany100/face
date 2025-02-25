import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_services.dart';
import '../pages/Auth/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/Drawer/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.user;

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade400,),
            padding: const EdgeInsets.all(10),
            child: Column(
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
                        backgroundImage: userData?.imageUrl != null && userData!.imageUrl.isNotEmpty
                            ? NetworkImage(userData.imageUrl) as ImageProvider
                            : const AssetImage("assets/unknown.png"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      userData?.name ?? 'Unknown User',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.black),
              title: const Text("Dashboard", style: TextStyle(fontSize: 19)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              )),
          ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text("Profile", style: TextStyle(fontSize: 19)),
              onTap: () {
                if (userData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(personID: userData.docID,)),
                  );
                }
                else{
                  print("user data doesn't exist");
                }
              }
          ),
          ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text("Settings", style: TextStyle(fontSize: 19)),
              onTap: () {}
          ),
          ListTile(
              leading: const Icon(Icons.login_outlined, color: Colors.black),
              title: const Text("Log out", style: TextStyle(fontSize: 19)),
              onTap: () async {
                await FirebaseService().logout();
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
