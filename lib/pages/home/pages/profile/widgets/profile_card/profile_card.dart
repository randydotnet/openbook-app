import 'package:Openbook/models/user.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_bio.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_counts/profile_counts.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/profile_details.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/widgets/profile_location.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_name.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/widgets/profile_url.dart';
import 'package:Openbook/pages/home/pages/profile/widgets/profile_card/widgets/profile_username.dart';
import 'package:Openbook/widgets/avatars/user_avatar.dart';
import 'package:flutter/material.dart';

class OBProfileCard extends StatelessWidget {
  final User user;

  OBProfileCard(this.user);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50), topLeft: Radius.circular(50)),
              color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: OBUserAvatar.AVATAR_SIZE_LARGE,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          OBProfileName(user),
                          OBProfileUsername(user)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  OBProfileBio(user),
                  OBProfileDetails(user),
                  OBProfileCounts(user)
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -((OBUserAvatar.AVATAR_SIZE_LARGE / 2) * 0.7),
          left: 30,
          child: OBUserAvatar(
            avatarUrl: user.getProfileAvatar(),
            size: OBUserAvatarSize.large,
          ),
        ),
      ],
    );
  }
}
