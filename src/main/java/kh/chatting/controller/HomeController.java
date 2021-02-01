package kh.chatting.controller;

import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import kh.chatting.dto.FriendDTO;
import kh.chatting.dto.UserDTO;
import kh.chatting.service.ChattingService;

@Controller
public class HomeController {
	@Autowired
	private HttpSession session;
	@Autowired
	private ChattingService service;
	
	@RequestMapping("/")
	public String home() {
		/* session.setAttribute("id","Test"); */
		return "home";
	}
	
	@RequestMapping("/chat")
	public String chat(Model model,HttpServletRequest request) {
		String userId = request.getParameter("userId");
		session.setAttribute("userId",userId);
		
		// 유저 정보
		UserDTO user = service.getUserInfo(userId);
		
		// 친구리스트
		List<FriendDTO> list = service.getFriendsList(userId); 
		
		model.addAttribute("user", user);
		model.addAttribute("list",list);

		return "chat";
	}
}
