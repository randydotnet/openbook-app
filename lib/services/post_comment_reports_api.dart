import 'package:Openbook/services/httpie.dart';
import 'package:Openbook/services/string_template.dart';
import 'package:meta/meta.dart';

class PostCommentReportsApiService {
  HttpieService _httpService;
  StringTemplateService _stringTemplateService;

  String apiURL;

  static const CREATE_POST_COMMENT_REPORT_PATH = 'api/posts/{postUuid}/comments/{postCommentId}/reports/';
  static const GET_REPORTS_FOR_POST_COMMENT_PATH = 'api/posts/{postUuid}/comments/{postCommentId}/reports/';
  static const GET_REPORTED_POST_COMMENTS_FOR_COMMUNITY_PATH = 'api/communities/{communityName}/posts/comments/reports/';
  static const CONFIRM_POST_COMMENT_REPORT_PATH = 'api/posts/{postUuid}/comments/{postCommentId}/reports/{reportId}/confirm/';
  static const REJECT_POST_COMMENT_REPORT_PATH = 'api/posts/{postUuid}/comments/{postCommentId}/reports/{reportId}/reject/';
  static const GET_REPORT_CATEGORIES = 'api/reports/categories/';


  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getReportsForPostComment({@required String postUuid, @required int postCommentId}) {

    String path = _makeGetPostCommentReportsPath(postUuid, postCommentId);
    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> createPostCommentReport(
      {@required String postUuid, @required int postCommentId, @required String categoryName, String comment}) {
    Map<String, dynamic> body = {};

    if (categoryName != null) {
      body['category_name'] = categoryName;
    }

    if (comment != null) {
      body['comment'] = comment;
    }

    String path = _makeCreatePostCommentReportPath(postUuid, postCommentId);

    return _httpService.putMultiform(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> confirmPostCommentReport(String postUuid, int postCommentId, int reportId) {
    String path = _makeConfirmPostCommentReportPath(postUuid, postCommentId, reportId);

    return _httpService.post(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReportCategories() {
    return _httpService.get(_makeApiUrl(GET_REPORT_CATEGORIES), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> rejectPostCommentReport(String postUuid, int postCommentId, int reportId) {
    String path = _makeRejectPostCommentReportPath(postUuid, postCommentId, reportId);

    return _httpService.post(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReportedPostCommentsForCommunityWithName(String communityName) {
    String url = _makeGetCommunityReportedPostCommentsPath(communityName);

    return _httpService.get(_makeApiUrl(url),
        appendAuthorizationToken: true);
  }

  String _makeGetCommunityReportedPostCommentsPath(String communityName) {
    return _stringTemplateService
        .parse(GET_REPORTED_POST_COMMENTS_FOR_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeConfirmPostCommentReportPath(String postUuid,  int postCommentId, int reportId) {
    return _stringTemplateService.parse(CONFIRM_POST_COMMENT_REPORT_PATH, {'postUuid': postUuid, 'postCommentId': postCommentId, 'reportId': reportId});
  }

  String _makeRejectPostCommentReportPath(String postUuid,  int postCommentId, int reportId) {
    return _stringTemplateService.parse(REJECT_POST_COMMENT_REPORT_PATH, {'postUuid': postUuid, 'postCommentId': postCommentId, 'reportId': reportId});
  }

  String _makeGetPostCommentReportsPath(String postUuid, int postCommentId) {
    return _stringTemplateService
        .parse(GET_REPORTS_FOR_POST_COMMENT_PATH, {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeCreatePostCommentReportPath(String postUuid, int postCommentId) {
    return _stringTemplateService
        .parse(CREATE_POST_COMMENT_REPORT_PATH, {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
