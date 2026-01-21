class NewsCommentModel {
  final String id;
  final int newsId;
  final String? parentId;
  final String? replyId;
  final String comment;
  final String created;
  final String creator;
  final String creatorId;
  final String note;
  final bool isDeleted;
  final bool active;

  NewsCommentModel({
    required this.id,
    required this.newsId,
    this.parentId,
    this.replyId,
    required this.comment,
    required this.created,
    required this.creator,
    required this.creatorId,
    required this.note,
    required this.isDeleted,
    required this.active,
  });

  factory NewsCommentModel.fromJson(Map<String, dynamic> json) {
    return NewsCommentModel(
      id: json['id'] ?? '',
      newsId: json['newsId'] ?? 0,
      parentId: json['parentId'],
      replyId: json['replyId'],
      comment: json['comment'] ?? '',
      created: json['created'] ?? '',
      creator: json['creator'] ?? '',
      creatorId: json['creatorId'] ?? '',
      note: json['note'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      active: json['active'] ?? false,
    );
  }
}

class NewsCommentsResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final List<NewsCommentModel> data;

  NewsCommentsResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory NewsCommentsResponse.fromJson(Map<String, dynamic> json) {
    return NewsCommentsResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      totalRecord: json['totalRecord'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NewsCommentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GetNewsCommentsRequest {
  final String newsId;

  GetNewsCommentsRequest({required this.newsId});

  Map<String, dynamic> toJson() {
    return {'NewsId': newsId};
  }
}

class AddNewsCommentRequest {
  final String newsId;
  final String commentText;
  final String? parentId;
  final String? replyId;

  AddNewsCommentRequest({
    required this.newsId,
    required this.commentText,
    this.parentId,
    this.replyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'NewsId': newsId,
      'CommentText': commentText,
      if (parentId != null) 'ParentId': parentId,
      if (replyId != null) 'ReplyId': replyId,
    };
  }
}
