<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Chat List</title>
<style>
	tr, td{
		border: 1px solid black;
	}
</style>
</head>
<body>
	<table>
		<th>채팅방</th>
		<th>${user.getUserName() }</th>
		<c:choose>
			<c:when test="${list != null }">
				<c:forEach var="dto" items="${list}">
					<tr>
						<td>이미지</td>
						<td>${dto.getRoomNumber() }</td>
						<td>${dto.getRoomName() }</td>
					</tr>
				</c:forEach>
			</c:when>
			<c:otherwise>채팅방이 없습니다.</c:otherwise>
		</c:choose>
	</table>
</body>
</html>