enum RouteDistinction {
  // PostListPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  postListPageObsPostToSpecificPostPage,

  // PostListPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  postListPageInqPostToSpecificPostPage,

  // KeywordPostListPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  keywordPostListPageObsPostToSpecificPostPage,
  
  // KeywordPostListPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  keywordPostListPageInqPostToSpecificPostPage,

  // WhatIWrotePage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  whatIWrotePageObsPostToSpecificPostPage,

  // WhatIWrotePage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  whatIWrotePageInqPostToSpecificPostPage,

  // WhatICommentPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  whatICommentPageObsPostToSpecificPostPage,

  // WhatICommentPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명하는 상수값
  whatICommentPageInqPostToSpecificPostPage,

  // NotificationPage의 장애 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명 상수값
  notificationPageObsToSpecifcPostPage,

  // NotificationPage의 문의 처리현황 게시물을 Tab -> SpecificPostPage로 Routing할 떄 증명 상수값
  notificationPageInqToSpecifcPostPage,

  // 스마트폰 환경에 표시된 알림을 Tab (알림과 관련된 게시물이 장애 처리현황 게시물일 떄 ) -> specificPostPage로 Routing할 떄 증명 상수값
  smartPhoneNotificaitonObsToSpecificPostPage,

  // 스마트폰 환경에 표시된 알림을 Tab (알림과 관련된 게시물이 문의 처리현황 게시물일 떄 ) -> specificPostPage로 Routing할 떄 증명 상수값
  smartPhoneNotificaitonInqToSpecificPostPage,
}