import 'package:flutter/material.dart';
import 'package:piggy_flutter/blocs/account_bloc.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/blocs/category_bloc.dart';
import 'package:piggy_flutter/blocs/user_bloc.dart';
import 'package:piggy_flutter/models/account.dart';
import 'package:piggy_flutter/models/category.dart';
import 'package:piggy_flutter/models/user.dart';
import 'package:piggy_flutter/ui/pages/category/category_list.dart';
import 'package:piggy_flutter/ui/pages/home/home.dart';
import 'package:piggy_flutter/ui/pages/login/login_page.dart';
import 'package:piggy_flutter/ui/widgets/about_tile.dart';

class CommonDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    final CategoryBloc categoryBloc = BlocProvider.of<CategoryBloc>(context);
    final AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          drawerHeader(userBloc),
          ListTile(
            title: Text(
              "Home",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            onTap: (() => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
          ),
          accountsTile(accountBloc),
          categoriesTile(categoryBloc),
          Divider(),
          ListTile(
            title: Text(
              "Logout",
            ),
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            onTap: (() {
              userBloc.logout().then((done) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ));
            }),
          ),
          Divider(),
          MyAboutTile()
        ],
      ),
    );
  }

  Widget categoriesTile(CategoryBloc categoryBloc) {
    return StreamBuilder<List<Category>>(
      stream: categoryBloc.categories,
      builder: (context, snapshot) {
        return ListTile(
          title: Text(
            "Categories",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
          ),
          leading: Icon(
            Icons.category,
            color: Colors.cyan,
          ),
          onTap: (() => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CategoryListPage()),
              )),
          trailing: snapshot.hasData
              ? Chip(
                  key: ValueKey<String>(snapshot.data.length.toString()),
                  backgroundColor: Colors.cyan,
                  label: Text(snapshot.data.length.toString()),
                )
              : Chip(
                  label: Icon(Icons.hourglass_empty),
                ),
        );
      },
    );
  }

  Widget accountsTile(AccountBloc accountBloc) {
    return StreamBuilder<List<Account>>(
      stream: accountBloc.userAccounts,
      builder: (context, snapshot) {
        return ListTile(
          title: Text(
            "Accounts",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
          ),
          leading: Icon(
            Icons.account_balance_wallet,
            color: Colors.green,
          ),
          onTap: (() => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          startpage: StartPage.Accounts,
                        )),
              )),
          trailing: snapshot.hasData
              ? Chip(
                  key: ValueKey<String>(snapshot.data.length.toString()),
                  backgroundColor: Colors.green,
                  label: Text(snapshot.data.length.toString()),
                )
              : Chip(
                  label: Icon(Icons.hourglass_empty),
                ),
        );
      },
    );
  }

  Widget drawerHeader(UserBloc userBloc) {
    return StreamBuilder<User>(
      stream: userBloc.user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return UserAccountsDrawerHeader(
            accountName: Text(
              '${snapshot.data.name} ${snapshot.data.surname}',
            ),
            accountEmail: Text(
              snapshot.data.emailAddress,
            ),
            currentAccountPicture: new CircleAvatar(
//              backgroundImage: new AssetImage(UIData.pkImage),
                ),
          );
        } else {
          return DrawerHeader(
            child: Text('User not logged in'),
          );
        }
      },
    );
  }
}
