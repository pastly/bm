m4_define(`START_HTML', 
<!DOCTYPE html>
<html>
<head>
  <title>$1 - system33 blog</title>
  <!-- <link href="/common/style.css" rel="stylesheet" type="text/css" />
  <link href="/common/font.css" rel="stylesheet" type="text/css">
  <link rel="shortcut icon" href="/common/favicon.ico" type="image/x-icon">
  <link rel="icon" href="/common/favicon.ico" type="image/x-icon">
  -->
  <meta charset="utf-8"/>
</head>
<body>
)
m4_define(`END_HTML',
</body>
</html>
)
m4_define(`HEADER_HTML',
m4_include(`include/header.html')
)
m4_define(`POST_HEADER_HTML',
HEADER_HTML
m4_include(`include/post.header.html')
)
m4_define(`FOOTER_HTML',
m4_include(`include/footer.html')
)
