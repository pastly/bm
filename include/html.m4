m4_define(`START_HTML', 
<!DOCTYPE html>
<html>
<head>
  <title>$1</title>
  <link href="/static/style.css" rel="stylesheet" type="text/css" />
  <!-- <link href="/common/font.css" rel="stylesheet" type="text/css">
  <link rel="shortcut icon" href="/common/favicon.ico" type="image/x-icon">
  <link rel="icon" href="/common/favicon.ico" type="image/x-icon">
  -->
  <meta charset="utf-8"/>
</head>
<body>
<div id='divbodyholder'>
)

m4_define(`END_HTML',
</div> <!-- divbodyholder -->
</body>
</html>
)

m4_define(`HEADER_HTML',
<div id='headerholder'>
<div id='header'>
m4_include(`include/header.html')
</div> <!-- header -->
</div> <!-- headerholder -->
<div id='divbody'>
)

m4_define(`POST_HEADER_HTML',
HEADER_HTML($1)
m4_include(`include/post.header.html')
)

m4_define(`FOOTER_HTML',
</div> <!-- divbody -->
<div id='footerholder'>
<div id='footer'>
m4_include(`include/footer.html')
</div> <!-- footer -->
</div> <!-- footerholder -->
)
