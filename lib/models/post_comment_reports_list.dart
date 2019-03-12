import 'package:Openbook/models/post_comment_report.dart';

class PostCommentReportsList {
  final List<PostCommentReport> reports;

  PostCommentReportsList({
    this.reports,
  });

  factory PostCommentReportsList.fromJson(List<dynamic> parsedJson) {
    List<PostCommentReport> reports =
    parsedJson.map((postJson) => PostCommentReport.fromJson(postJson)).toList();

    return new PostCommentReportsList(
      reports: reports,
    );
  }
}
