import 'package:Openbook/models/community.dart';
import 'package:Openbook/models/post.dart';
import 'package:Openbook/models/theme.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/services/theme.dart';
import 'package:Openbook/services/theme_value_parser.dart';
import 'package:Openbook/widgets/buttons/button.dart';
import 'package:Openbook/widgets/buttons/floating_action_button.dart';
import 'package:Openbook/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBCommunityNewPostButton extends StatelessWidget {
  final bool isDisabled;
  final bool isLoading;
  final Color textColor;
  final OBButtonSize size;
  final double minWidth;
  final EdgeInsets padding;
  final OBButtonType type;
  final Community community;
  final ValueChanged<Post> onPostCreated;

  const OBCommunityNewPostButton({
    this.type = OBButtonType.primary,
    this.size = OBButtonSize.medium,
    this.textColor = Colors.white,
    this.isDisabled = false,
    this.isLoading = false,
    this.padding,
    this.minWidth,
    this.community,
    this.onPostCreated,
  });

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community community = snapshot.data;

        if (community == null) return const SizedBox();

        String communityHexColor = community.color;
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        ThemeValueParserService themeValueParserService =
            openbookProvider.themeValueParserService;
        ThemeService themeService = openbookProvider.themeService;

        OBTheme currentTheme = themeService.getActiveTheme();
        Color currentThemePrimaryColor =
            themeValueParserService.parseColor(currentTheme.primaryColor);
        double currentThemePrimaryColorLuminance =
            currentThemePrimaryColor.computeLuminance();

        Color communityColor =
            themeValueParserService.parseColor(communityHexColor);
        Color textColor = themeValueParserService.isDarkColor(communityColor)
            ? Colors.white
            : Colors.black;
        double communityColorLuminance = communityColor.computeLuminance();

        if (communityColorLuminance > 0.9 &&
            currentThemePrimaryColorLuminance > 0.9) {
          // Is extremely white and our current theem is also extremely white, darken it
          communityColor = TinyColor(communityColor).darken(5).color;
        } else if (communityColorLuminance < 0.1) {
          // Is extremely dark and our current theme is also extremely dark, lighten it
          communityColor = TinyColor(communityColor).lighten(10).color;
        }

        return OBFloatingActionButton(
            color: communityColor,
            textColor: textColor,
            onPressed: () async {
              OpenbookProviderState openbookProvider =
                  OpenbookProvider.of(context);
              Post post = await openbookProvider.modalService
                  .openCreatePost(context: context, community: community);
              if (post != null && onPostCreated != null) onPostCreated(post);
            },
            child: OBIcon(OBIcons.createPost,
                size: OBIconSize.large, color: textColor));
      },
    );
  }
}
