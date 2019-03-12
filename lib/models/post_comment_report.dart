import 'package:Openbook/models/post.dart';
import 'package:Openbook/models/post_comment.dart';
import 'package:Openbook/models/report_category.dart';
import 'package:Openbook/models/user.dart';

class PostCommentReport {
  final int id;
  final PostComment postComment;
  final User reporter;
  final String comment;
  final String status;
  final ReportCategory category;
  final DateTime created;

  PostCommentReport(
      { this.id,
        this.postComment,
        this.reporter,
        this.comment,
        this.status,
        this.category,
        this.created
      });

  factory PostCommentReport.fromJson(Map<String, dynamic> parsedJson) {
    PostComment postComment;
    User reporter;
    DateTime created;

    if (parsedJson['created'] != null) {
      created = DateTime.parse(parsedJson['created']).toLocal();
    }

    if (parsedJson.containsKey('post_comment')) {
      postComment = PostComment.fromJson(parsedJson['post_comment']);
    }

    if (parsedJson.containsKey('reporter')) {
      reporter = User.fromJson(parsedJson['reporter']);
    }

    return PostCommentReport(
        postComment: postComment,
        id: parsedJson['id'],
        reporter: reporter,
        status: parsedJson['status'],
        comment: parsedJson['comment'],
        category: ReportCategory.fromJson(parsedJson['category']),
        created: created
    );
  }
}
