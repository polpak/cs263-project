<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
	if(session.getAttribute("email_address") != null)
		response.sendRedirect("/user/profile.jsp");
	else {
		response.sendRedirect("/user/signup.jsp");
	}
%>
