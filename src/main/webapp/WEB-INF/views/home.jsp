<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
<head>
	<title>Home</title>
</head>
<body>
	<input id="userId" type="text" placeholder="input Id">
	<input type="button" value="send" id="sendBtn">
	<script>
		document.getElementById("sendBtn").onclick = function(){
			console.log("this is  home");
			let userId = document.getElementById("userId").value;
			location.href="/chat?userId="+userId;
		}
	</script>
</body>
</html>
