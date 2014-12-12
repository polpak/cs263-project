<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
	session.removeAttribute("email_address");
	response.sendRedirect("/user/login.jsp");
%>