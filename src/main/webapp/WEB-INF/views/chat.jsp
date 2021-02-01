<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.3.0/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<style>
	*{
		box-sizing: border-box;
		padding: 0px;
		margin: 0px;
	}
	.container>div{
		border: 1px solid black;
	}
	.container{
		display: flex;
	}
	.contents .me{
		text-align: right;
	}
	.contents .others{
		text-align: left;
	}
	
	/* Profile */
	.profile{
		padding: 10px;	
	}
	.friend,
	.myProfile {
		display: flex;
		margin: 6px 0px;
		align-items: center;
	}
	.profileImg{
		padding-right: 6px;
	}
	.friendName {
		cursor: pointer;
	}
</style>
</head>
<body>
	<div class="container">
		<div class="profile">
			<div class="myProfile">
				<div class="profileImg user">이미지</div>
				<input type="hidden" id="userId" value=${user.getUserId() }>
				<div id="userName">${user.getUserName() }</div>
			</div>
			<div class="otherProfile">
				<c:choose>
					<c:when test="${list != null }">
						<c:forEach var="dto" items="${list }">
							<div class="friend">
								<div class="profileImg friend">이미지</div>
								<div class="friendName" id="friendName">${dto.getFriendName() }</div>
								<input type="hidden" value="${dto.getFriendId() }" class="friendId" id="friendId">				
							</div>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<div>친구가 없습니다!</div>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
		<div class="chatContainer">
			<input type="text" id="roomNumber" value="roomNumber">
			<div class="contents"></div>
			<div class="sendMsg">
				<input type="text" id="message">
				<button id="send">Send</button>
			</div>
		</div>
	</div>
	
	<script>
		var socket = new SockJS("/wechat"); // 엔드포인트 주소 넣기
		var client = Stomp.over(socket); // 연결 이후 작업 처리하는 코드
		
		client.connect({},function(resp){ // {}는 헤더정보 없으면  빈 칸
			console.log(resp);
			client.subscribe("/topic/chat/{roomNumber}",function(msg){ // 구독할 url 넣기
				var result = JSON.parse(msg.body);
				if(result.userId == $("#userId").val()){
					$(".contents").append("<p class='me'>"+result.message+"</p>");
				}else{
					$(".contents").append("<p class='others'>"+result.userId+" : "+result.message+"</p>");
				}
			});
			client.subscribe("/topic/roomCreate",function(msg){
				var result = JSON.parse(msg.body);
				if(result != null){
					$("#roomNumber").val(result.roomNumber);
				}else{
					alert("채팅방 생성 실패!");
				}
			});
		});
		
		$("#send").on("click",function(){
			var userId = $("#userId").val();
			var msg = $("#message").val();
			var roomNumber = $("#roomNumber").val();
			$("#message").val("");
			client.send("/app/chat",{},JSON.stringify({userId:userId,message:msg,roomNumber:roomNumber})); // 세번째 인자값은 보내려는 메세지(String 혹은 json 형태로)
		});
		
		$("#friendName").on("dblclick",function(){
			var userId = $("#userId").val();
			var friendId = $("#friendId").val();
			var userName = $("#userName").text();
			var friendName = $("#friendName").text();
			var roomNumber = userId+'_'+friendId;
			var roomName = userName+'와 '+friendName+'의 채팅방';
			
			client.send("/app/roomCheck",{},JSON.stringify({userId:userId,friendId:friendId,roomNumber:roomNumber,roomName:roomName}));
			client.subscribe("/topic/roomCheck",function(msg){
				console.log("요기는 룸체크 구독")
				var result = JSON.parse(msg.body);
				$("#roomNumber").val(result.roomNumber);
			});
		});
	</script>
</body>
</html>