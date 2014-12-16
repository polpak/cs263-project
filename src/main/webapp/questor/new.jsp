<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.EntityNotFoundException" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>

<%@ page import="questor.User" %>
<%@ page import="questor.Quest" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
	if(session.getAttribute("email_address") == null) {
		response.sendRedirect("/user/login.jsp");
	} else { 
		User user = User.fromEmailAddress((String)session.getAttribute("email_address"));
%>

<!DOCTYPE html>
	<html>
	<head>
	<title>Questor - The world is your RPG</title>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	<script type="text/javascript">

	$( document ).ready(function() {
		$("#new-quest-form").submit(function(e)
				{
					var postData = $(this).serializeArray();
					var questData = {};
					$.each( postData, function( i, field ) {
						questData[field.name] = field.value;
					});
					
					questData["reward"] = Number(questData["reward"]);
					var jsonData = JSON.stringify(questData);
				    e.preventDefault();
				    
				    success = function(data, textStatus, jqXHR) {
				    	window.location = "/user/profile.jsp";
				    }
				    
				    error = function(data, textStatus, jqXHR) {
				    	alert("There was an error creating the quest");
				    }
				    
				    $.ajax({
				    		type: "POST",
							url: "/quests/new",
							data: jsonData,
							success: success,
							contentType: "application/json"
							});
				});
	});
		
	</script>
	<link type="text/css" rel="stylesheet" href="/css/main.css"/>
	</head>
	<body>
		<h1>Create a new Quest</h1>
		<form id="new-quest-form">
		<% 
		String [] fieldList= {"Title", "Description", "Reward"};
		for(String field : fieldList) {
			String lower = field.toLowerCase();
			String type = "text";
			if( lower.equals("description")){
				type = "textarea";
			}
			
			StringBuffer formElem = new StringBuffer(String.format("<label for=\"%s\">%s</label>", lower, field));
			if(type.equals("textarea")) 
				formElem.append(String.format("<textarea rows=\"5\" cols=\"50\" name=\"%s\" id=\"%s\" required></textarea>",
												lower, lower));
			else 
				formElem.append(String.format("<input type=\"%s\" name=\"%s\" id=\"%s\" value=\"\" required>", 
												type, lower, lower));
			
		%>
			<%=formElem.toString()%><br>
		<% } %>
		<input type="submit" name="Create Quest" value="Create Quest">
		</form>
	</body>
	</html>
	
<% } %>