import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/blocs/transaction_detail/bloc.dart';
import 'package:piggy_flutter/dashboard/dashboard_page.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/screens/account/account_form.dart';
import 'package:piggy_flutter/screens/account/account_list.dart';
import 'package:piggy_flutter/screens/home/overview_screen.dart';
import 'package:piggy_flutter/screens/home/recent_transactions.dart';
import 'package:piggy_flutter/screens/transaction/transaction_detail.dart';
import 'package:piggy_flutter/screens/transaction/transaction_form.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/common.dart';
import 'package:piggy_flutter/widgets/common/common.dart';

import 'bottom_bar_view.dart';

class TabIconData {
  TabIconData({
    this.index = 0,
    this.isSelected = false,
    this.iconData,
    this.animationController,
  });

  bool isSelected;
  int index;
  IconData iconData;

  AnimationController animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      iconData: MaterialCommunityIcons.desktop_mac_dashboard,
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      iconData: MaterialCommunityIcons.calendar_month_outline,
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      iconData: MaterialCommunityIcons.bank,
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      iconData: MaterialCommunityIcons.finance,
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, this.startpage = StartPage.Dashboard})
      : super(key: key);

  final StartPage startpage;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  int _selectedNavIndex = 0;

  Widget tabBody = Container(
    color: PiggyAppTheme.background,
  );

  @override
  void initState() {
    for (TabIconData tab in tabIconsList) {
      tab.isSelected = false;
    }
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    if (widget.startpage == StartPage.Dashboard) {
      tabBody = OverviewScreen(animationController: animationController);
    } else if (widget.startpage == StartPage.Accounts) {
      tabBody = AccountListPage(
        animationController: animationController,
      );
    }

    initPlatformState();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PiggyAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
        drawer: CommonDrawer(
          animationController: animationController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      final Map<String, dynamic> transactionData =
          result.notification.payload.additionalData;

      try {
        final Transaction transaction = Transaction(
            id: transactionData['TransactionId'],
            transactionTime: transactionData['TransactionTime'],
            description: transactionData['Description'],
            amount: double.tryParse(transactionData['Amount']),
            categoryName: transactionData['CategoryName'],
            creatorUserName: transactionData['CreatorUserName'],
            accountName: transactionData['AccountName']);
        // TODO(abhith): get data from Id rather than sending over notification

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => TransactionDetailPage(
                transaction: transaction,
                transactionDetailBloc:
                    BlocProvider.of<TransactionDetailBloc>(context),
              ),
              fullscreenDialog: true,
            ));
      } catch (e) {
        print(e);
      }
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            if (_selectedNavIndex == 2) {
              return Navigator.of(context)
                  .push(MaterialPageRoute<DismissDialogAction>(
                builder: (_) => const AccountFormScreen(
                  title: 'Add Account',
                ),
              ));
            }
            return Navigator.of(context).push(
              MaterialPageRoute<DismissDialogAction>(
                builder: (_) => TransactionFormPage(
                  transactionsBloc: BlocProvider.of<TransactionBloc>(context),
                ),
              ),
            );
          },
          changeIndex: (int index) {
            if (index == 0) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      OverviewScreen(animationController: animationController);
                  _selectedNavIndex = index;
                });
              });
            } else if (index == 1) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = RecentTransactionsPage(
                    animationController: animationController,
                  );
                  _selectedNavIndex = index;
                });
              });
            } else if (index == 2) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = AccountListPage(
                    animationController: animationController,
                  );
                  _selectedNavIndex = index;
                });
              });
            } else if (index == 3) {
              animationController.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody = DashboardPage();
                  _selectedNavIndex = index;
                  // TrainingScreen(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}
