enum RouteDistinction {
  // PostListPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  postListPageObsPostToSpecificPostPage,

  // PostListPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  postListPageInqPostToSpecificPostPage,

  // KeywordPostListPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  keywordPostListPageObsPostToSpecificPostPage,
  
  // KeywordPostListPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  keywordPostListPageInqPostToSpecificPostPage,

  // WhoIWrotePage -> SpecificPostPage로 Routing할 떄 증명 상수값
  whatIWrotePage_to_specificPostPage,

  // WhoICommentPage ->  SpecificPostPage로 Routing할 떄 증명 상수값
  whatICommentPage_to_specificPostPage,

  // NotificationPage -> SpecificPostPage로 Routing할 떄 증명 상수값
  notificationPage_to_specifcPostPage,
}