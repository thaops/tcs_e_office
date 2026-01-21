class NewsModel {
  final int id;
  final String title;
  final String content;
  final String createdDate;
  final String approvedDate;
  final bool isNew;
  final String department;
  final String categoryCode;
  final bool isActive;
  final int status;
  final List<dynamic> attachments;
  final String thumbAttachmentUrl;
  final int totalLike;
  final int totalViewed;
  final int totalComment;
  final String creator;
  final String updatedDate;
  final String approver;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.approvedDate,
    required this.isNew,
    required this.department,
    required this.categoryCode,
    required this.isActive,
    required this.status,
    required this.attachments,
    required this.thumbAttachmentUrl,
    required this.totalLike,
    required this.totalViewed,
    required this.totalComment,
    required this.creator,
    required this.updatedDate,
    required this.approver,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdDate: json['createdDate'] ?? '',
      approvedDate: json['approvedDate'] ?? '',
      isNew: json['isNew'] ?? false,
      department: json['department'] ?? '',
      categoryCode: json['categoryCode'] ?? '',
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 0,
      attachments: json['attachments'] ?? [],
      thumbAttachmentUrl: json['thumbAttachmentUrl'] ?? '',
      totalLike: json['totalLike'] ?? 0,
      totalViewed: json['totalViewed'] ?? 0,
      totalComment: json['totalComment'] ?? 0,
      creator: json['creator'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
      approver: json['approver'] ?? '',
    );
  }
}

class NewsDetailModel {
  final int id;
  final String title;
  final String content;
  final String createdDate;
  final int totalViewed;
  final int totalLike;
  final int totalComment;
  final bool isLiked;

  NewsDetailModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.totalViewed,
    required this.totalLike,
    required this.totalComment,
    required this.isLiked,
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) {
    return NewsDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdDate: json['createdDate'] ?? '',
      totalViewed: json['totalViewed'] ?? 0,
      totalLike: json['totalLike'] ?? 0,
      totalComment: json['totalComment'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}

class NewsDetailResponse {
  final int statusCode;
  final String message;
  final NewsDetailModel? data;

  NewsDetailResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory NewsDetailResponse.fromJson(Map<String, dynamic> json) {
    return NewsDetailResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? NewsDetailModel.fromJson(json['data'])
          : null,
    );
  }
}

class NewsResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final List<NewsModel> data;

  NewsResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      totalRecord: json['totalRecord'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class NewsRequest {
  final String keyword;
  final int? pageIndex;
  final int? pageSize;

  NewsRequest({this.keyword = '', this.pageIndex, this.pageSize});

  Map<String, dynamic> toJson() {
    return {
      'Keyword': keyword,
      if (pageIndex != null) 'PageIndex': pageIndex,
      if (pageSize != null) 'PageSize': pageSize,
    };
  }
}

class NewsDetailRequest {
  final String id;

  NewsDetailRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {'Id': id};
  }
}
