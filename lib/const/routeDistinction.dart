enum RouteDistinction {
  // PostListPage에 표현된 IT 요청건 게시물을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  POSTLISTPAGE_TO_SPECIFICPOSTPAGE,

  // KeywordListPage에 표현된 IT 요청건 게시물을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  KEYWORDPOSTLISTPAGE_TO_SPECIFICPOSTPAGE,

  // whatIWrotePage에 표현된 IT 요청건 게시물을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  WHATIWROTEPAGE_TO_SPECIFICPOSTPAGE,

  // whatIcommentPage에 표현된 IT 요청건 게시물을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  WHATICOMMENTPAGE_TO_SPECIFICPOSTPAGE,

  // NotificationPage에 표현된 알림을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  NOTIFICATIONPAGE_TO_SPECIFICPOSTPAGE,

  // 스마트폰 환경에 표시된 알림을 클릭해서 SpecificPostPage로 Routing할 떄 어디서 왔는지 증명하는 enum값
  SMARTPHONENOTIFICATION_TO_SPECIFICPOSTPAGE,
}