import 'package:Openbook/libs/str_utils.dart';
import 'package:Openbook/models/community.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/services/httpie.dart';
import 'package:Openbook/services/navigation_service.dart';
import 'package:Openbook/services/toast.dart';
import 'package:Openbook/widgets/http_list.dart';
import 'package:Openbook/widgets/icon.dart';
import 'package:Openbook/widgets/theming/secondary_text.dart';
import 'package:Openbook/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMyCommunitiesGroup extends StatefulWidget {
  final OBHttpListRefresher<Community> communityGroupListRefresher;
  final OBHttpListItemBuilder<Community> communityGroupListItemBuilder;
  final OBHttpListOnScrollLoader<Community> communityGroupListOnScrollLoader;
  final OBMyCommunitiesGroupFallbackBuilder noGroupItemsFallbackBuilder;
  final OBMyCommunitiesGroupController controller;
  final String groupItemName;
  final String groupName;
  final int maxGroupListPreviewItems;
  final String title;

  const OBMyCommunitiesGroup({
    Key key,
    @required this.communityGroupListRefresher,
    @required this.communityGroupListOnScrollLoader,
    @required this.groupItemName,
    @required this.groupName,
    @required this.title,
    @required this.maxGroupListPreviewItems,
    @required this.communityGroupListItemBuilder,
    this.noGroupItemsFallbackBuilder,
    this.controller,
  }) : super(key: key);

  @override
  OBMyCommunitiesGroupState createState() {
    return OBMyCommunitiesGroupState();
  }
}

class OBMyCommunitiesGroupState extends State<OBMyCommunitiesGroup> {
  bool _needsBootstrap;
  ToastService _toastService;
  NavigationService _navigationService;
  List<Community> _communityGroupList;
  bool _refreshInProgress;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.attach(this);
    _needsBootstrap = true;
    _communityGroupList = [];
    _refreshInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    int listItemCount =
        _communityGroupList.length < widget.maxGroupListPreviewItems
            ? _communityGroupList.length
            : widget.maxGroupListPreviewItems;

    if (listItemCount == 0) {
      if (widget.noGroupItemsFallbackBuilder != null && !_refreshInProgress) {
        return widget.noGroupItemsFallbackBuilder(
            context, _refreshJoinedCommunities);
      }
      return const SizedBox();
    }

    List<Widget> columnItems = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: OBText(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: _buildCommunitySeparator,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shrinkWrap: true,
          itemCount: listItemCount,
          itemBuilder: _buildGroupListPreviewItem),
    ];

    if (_communityGroupList.length > widget.maxGroupListPreviewItems) {
      columnItems.add(_buildSeeAllButton());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnItems,
    );
  }

  Widget _buildSeeAllButton() {
    return GestureDetector(
      onTap: _onWantsToSeeAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OBSecondaryText(
              'See all ' + widget.groupName,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 5,
            ),
            OBIcon(OBIcons.seeMore, themeColor: OBIconThemeColor.secondaryText)
          ],
        ),
      ),
    );
  }

  Widget _buildGroupListPreviewItem(BuildContext context, index) {
    Community community = _communityGroupList[index];
    return widget.communityGroupListItemBuilder(context, community);
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  void _bootstrap() {
    _refreshJoinedCommunities();
  }

  Future<void> _refreshJoinedCommunities() async {
    _setRefreshInProgress(true);
    try {
      List<Community> groupCommunities =
          await widget.communityGroupListRefresher();
      _setCommunityGroupList(groupCommunities);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _onWantsToSeeAll() {
    _navigationService.navigateToBlankPageWithWidget(
        context: context,
        key: Key('obMyCommunitiesGroup' + widget.groupItemName),
        navBarTitle: capitalize(widget.groupName),
        widget: _buildSeeAllGroupItemsPage());
  }

  Widget _buildSeeAllGroupItemsPage() {
    return Column(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OBHttpList<Community>(
              separatorBuilder: _buildCommunitySeparator,
              listItemBuilder: widget.communityGroupListItemBuilder,
              listRefresher: widget.communityGroupListRefresher,
              listOnScrollLoader: widget.communityGroupListOnScrollLoader,
              resourcePluralName: widget.groupName,
              resourceSingularName: widget.groupItemName),
        )),
      ],
    );
  }

  void _setCommunityGroupList(List<Community> communities) {
    setState(() {
      _communityGroupList = communities;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

class OBMyCommunitiesGroupController {
  OBMyCommunitiesGroupState _state;

  void attach(OBMyCommunitiesGroupState state) {
    this._state = state;
  }

  Future<void> refresh() {
    return _state._refreshJoinedCommunities();
  }
}

typedef Future<void> OBMyCommunitiesGroupRetry();

typedef Widget OBMyCommunitiesGroupFallbackBuilder(
    BuildContext context, OBMyCommunitiesGroupRetry retry);
