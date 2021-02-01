package kh.chatting.controller;

import java.io.IOException;
import java.security.Principal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.ExecutionException;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import kh.chatting.dto.MessageDTO;
import kh.chatting.dto.RoomDTO;
import kh.chatting.service.ChattingService;

@Controller
public class ChatController {
	@Autowired
	private ChattingService service;

	// ----------------------------------------------------------------------- chat
	
	private final SimpMessagingTemplate template;

	@Autowired
	public ChatController(SimpMessagingTemplate template) {
		this.template = template;
	}

	// 채팅 메세지 전달
	@MessageMapping("/chat") // 리퀘스트가 http를 통해 접속하는 경우 쓰임. 웹소켓 접속은 다른 어노테이션
	// @SendTo("/topic") // Proc 메서드 작업이 끝나면 response를 구독하는 사람한테만 메세지 보내는 설정 가능
	public void chat(MessageDTO dto) {
		System.out.println("여기는  챗!");
		int result = service.insertMessage(dto.getUserId(),dto.getMessage(),dto.getRoomNumber());
		if(result>0) {
			template.convertAndSend("/topic/chat/"+dto.getRoomNumber(),dto);
			
		}
	}
	
	// ----------------------------------------------------------------------- Room

	// 채팅방 생성
	@MessageMapping("/roomCreate")
	public void createRoom(String roomNumber,String roomName) {
		System.out.println("여기는 룸생성!");
		int result = service.insertRoom(roomNumber,roomName);
		if(result>0) {
			RoomDTO dto = service.findRoomByRoomNumber(roomNumber);
			template.convertAndSend("/topic/roomCreate",dto);
		}
	}

	// 특정 채팅방 조회
	@MessageMapping("/roomCheck")
	public void roomInfo(String msg) {
		JSONObject obj = JsonToObjectParser(msg);
		String userId = (String) obj.get("userId");
		String friendId = (String) obj.get("friendId");
		String  roomNumber = (String)obj.get("roomNumber");
		String  roomName = (String)obj.get("roomName");
		RoomDTO dto = service.findRoomById(userId, friendId);
		if(dto != null) {
			template.convertAndSend("/topic/roomCheck",dto);
		}else {
			createRoom(roomNumber,roomName);
		}
		
	}
	
	private static JSONObject JsonToObjectParser(String jsonStr) {
		JSONParser parser = new JSONParser();
		JSONObject obj = null;
		try {
			obj = (JSONObject)parser.parse(jsonStr);
		}catch(ParseException e) {
			e.printStackTrace();
		}
		return obj;
		// json 형태의 문자열을 SimpleJson의 parser를 이용하여 JSONObject로 파싱처리
	}
}