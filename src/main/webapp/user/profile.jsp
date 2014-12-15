<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.EntityNotFoundException" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>

<%@ page import="questor.User" %>
<%@ page import="questor.Quest" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	if(session.getAttribute("email_address") == null) {
		response.sendRedirect("/user/login.jsp");
	} else { 
		User user = User.fromEmailAddress((String)session.getAttribute("email_address"));
		List<Quest> posted_quests = user.getPostedQuests();
		List<Quest> accepted_quests = user.getAcceptedQuests();
%>
<!DOCTYPE html>
	<html>
	<head>
	<title>Questor - The world is your RPG</title>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	<link type="text/css" rel="stylesheet" href="/css/main.css"/>
	</head>
	<body>
	<header>
		<h1>Questor!</h1>
		<h2>The world is your RPG.</h2>
	</header>
		<div id="user-profile">
	  		<img id="user-avatar" height="100" width="66" src="/user/avatar">
	  	<form action="<%= blobstoreService.createUploadUrl("/user/avatar") %>" method="post" enctype="multipart/form-data">
            <input type="file" name="user_avatar">
            <input type="submit" value="Update Avatar">
        </form>
	  		<span id="name"><%= user.getFirstName() %> <%= user.getLastName() %></span>
	  	</div>
	  	<div class="quest-container">
	  		<% if(!posted_quests.isEmpty()) { %>
			  	<table id="posted-quests">
			  			<tr class="header-row"><th>Title</th><th>Reward</th><th>Expiration</th><th>Status</th></tr>
			  			<%
			  				for(Quest quest : posted_quests){
			  				  				String status = "Looking for quester";
			  				  				if(quest.isAccepted()) {
			  				  					status = "In progress";
			  				  				}
			  				  				if(quest.isCompleted()) {
			  				  					status = "Complete";
			  				  				}
			  				  				else if(quest.getExpiration().before(new Date())) {
			  				  					status = "Expired";
			  				  				}
			  			%>
			  				<tr>
			  					<td><a href="/questor/show.jsp?k=<%=quest.getQuestKey()%>"><%=quest.getTitle()%></a></td>
			  					<td><%=quest.getReward()%></td>
			  					<td><%=quest.getExpiration()%></td>
			  					<td><%=status%></td>
			  				</tr>
			  		<%
			  			}
			  		%>
			  	</table>
		  	<%
		  		}
		  	%>
		  	<a href="/questor/new.jsp">Create a new quest!</a>
	  	</div>
	  	<div class="quest-container">
		  	<%
		  		if(!accepted_quests.isEmpty()) {
		  	%>
			  	<table id="accepted-quests">
			  			<tr class="header-row"><th>Title</th><th>Reward<th><th>Expiration</th><th>Status</th></tr>
			  			<%
			  				for(Quest quest : accepted_quests){
			  				  				String status = "In progress";
			  				  				
			  				  				if(quest.isCompleted()) {
			  				  					status = "Complete";
			  				  				}
			  				  				else if(quest.getExpiration().before(new Date())) {
			  				  					status = "Expired";
			  				  				}
			  			%>
			  				<tr>
			  					<td><a href="/questor/show.jsp?k=<%=quest.getQuestKey()%>"><%=quest.getTitle()%></a></td>
			  					<td><%=quest.getReward()%></td>
			  					<td><%=quest.getExpiration()%></td>
			  					<td><%=status %></td>
			  				</tr>
			  		<% } %>
			  	</table>
			<% } %>
			<a href="/questor/search.jsp">Find a quest!</a>
	  	</div>
	</body>
	</html>
	
<% } %>