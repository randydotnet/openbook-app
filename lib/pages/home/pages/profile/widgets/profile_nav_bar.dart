import 'package:Openbook/models/user.dart';
import 'package:Openbook/widgets/nav_bars/themed_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBProfileNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final User user;

  OBProfileNavBar(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: user.updateSubject,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          var user = snapshot.data;

          if (user == null) return const SizedBox();
          return OBThemedNavigationBar(
            title: '@' + user.username,
          );
        });
  }

  bool get fullObstruction {
    return true;
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }
}
