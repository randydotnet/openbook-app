import 'dart:io';

import 'package:Openbook/services/httpie.dart';
import 'package:Openbook/services/string_template.dart';
import 'package:meta/meta.dart';

class PostsApiService {
  HttpieService _httpService;
  StringTemplateService _stringTemplateService;

  String apiURL;

  static const GET_POSTS_PATH = 'api/posts/';
  static const GET_TRENDING_POSTS_PATH = 'api/posts/trending/';
  static const CREATE_POST_PATH = 'api/posts/';
  static const POST_PATH = 'api/posts/{postUuid}/';
  static const COMMENT_POST_PATH = 'api/posts/{postUuid}/comments/';
  static const MUTE_POST_PATH = 'api/posts/{postUuid}/notifications/mute/';
  static const UNMUTE_POST_PATH = 'api/posts/{postUuid}/notifications/unmute/';
  static const DELETE_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/';
  static const GET_POST_COMMENTS_PATH = 'api/posts/{postUuid}/comments/';
  static const REACT_TO_POST_PATH = 'api/posts/{postUuid}/reactions/';
  static const DELETE_POST_REACTION_PATH =
      'api/posts/{postUuid}/reactions/{postReactionId}/';
  static const GET_POST_REACTIONS_PATH = 'api/posts/{postUuid}/reactions/';
  static const GET_POST_REACTIONS_EMOJI_COUNT_PATH =
      'api/posts/{postUuid}/reactions/emoji-count/';
  static const GET_REACTION_EMOJI_GROUPS = 'api/posts/emojis/groups/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getTrendingPosts({bool authenticatedRequest = true}) {
    return _httpService.get('$apiURL$GET_TRENDING_POSTS_PATH',
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getTimelinePosts(
      {List<int> listIds,
      List<int> circleIds,
      int maxId,
      int count,
      String username,
      bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (listIds != null && listIds.isNotEmpty) queryParams['list_id'] = listIds;

    if (circleIds != null && circleIds.isNotEmpty)
      queryParams['circle_id'] = circleIds;

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (username != null) queryParams['username'] = username;

    return _httpService.get(_makeApiUrl(GET_POSTS_PATH),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieStreamedResponse> createPost(
      {String text, List<int> circleIds, File image, File video}) {
    Map<String, dynamic> body = {};

    if (image != null) {
      body['image'] = image;
    }

    if (video != null) {
      body['video'] = video;
    }

    if (text != null && text.length > 0) {
      body['text'] = text;
    }

    if (circleIds != null && circleIds.length > 0) {
      body['circle_id'] = circleIds.join(',');
    }

    return _httpService.putMultiform(_makeApiUrl(CREATE_POST_PATH),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostWithUuid(String postUuid) {
    String path = _makePostPath(postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostWithUuid(String postUuid) {
    String path = _makePostPath(postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getCommentsForPostWithUuid(String postUuid,
      {int count, int maxId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeGetPostCommentsPath(postUuid);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> commentPost(
      {@required String postUuid, @required String text}) {
    Map<String, dynamic> body = {'text': text};

    String path = _makeCommentPostPath(postUuid);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostComment(
      {@required postCommentId, @required postUuid}) {
    String path = _makeDeletePostCommentPath(
        postCommentId: postCommentId, postUuid: postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsForPostWithUuid(String postUuid,
      {int count, int maxId, int emojiId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (emojiId != null) queryParams['emoji_id'] = emojiId;

    String path = _makeGetPostReactionsPath(postUuid);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsEmojiCountForPostWithUuid(
      String postUuid) {
    String path = _makeGetPostReactionsEmojiCountPath(postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reactToPost(
      {@required String postUuid,
      @required int emojiId,
      @required int emojiGroupId}) {
    Map<String, dynamic> body = {'emoji_id': emojiId, 'group_id': emojiGroupId};

    String path = _makeReactToPostPath(postUuid);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostReaction(
      {@required postReactionId, @required postUuid}) {
    String path = _makeDeletePostReactionPath(
        postReactionId: postReactionId, postUuid: postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> mutePostWithUuid(String postUuid) {
    String path = _makeMutePostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unmutePostWithUuid(String postUuid) {
    String path = _makeUnmutePostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionEmojiGroups() {
    String url = _makeApiUrl(GET_REACTION_EMOJI_GROUPS);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makePostPath(String postUuid) {
    return _stringTemplateService.parse(POST_PATH, {'postUuid': postUuid});
  }

  String _makeMutePostPath(String postUuid) {
    return _stringTemplateService.parse(MUTE_POST_PATH, {'postUuid': postUuid});
  }

  String _makeUnmutePostPath(String postUuid) {
    return _stringTemplateService.parse(UNMUTE_POST_PATH, {'postUuid': postUuid});
  }

  String _makeCommentPostPath(String postUuid) {
    return _stringTemplateService
        .parse(COMMENT_POST_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostCommentsPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_COMMENTS_PATH, {'postUuid': postUuid});
  }

  String _makeDeletePostCommentPath(
      {@required postCommentId, @required postUuid}) {
    return _stringTemplateService.parse(DELETE_POST_COMMENT_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeReactToPostPath(String postUuid) {
    return _stringTemplateService
        .parse(REACT_TO_POST_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostReactionsPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_REACTIONS_PATH, {'postUuid': postUuid});
  }

  String _makeDeletePostReactionPath(
      {@required postReactionId, @required postUuid}) {
    return _stringTemplateService.parse(DELETE_POST_REACTION_PATH,
        {'postReactionId': postReactionId, 'postUuid': postUuid});
  }

  String _makeGetPostReactionsEmojiCountPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_REACTIONS_EMOJI_COUNT_PATH, {'postUuid': postUuid});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
