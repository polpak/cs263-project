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
	<link type="text/css" rel="stylesheet" href="/css/main.css"/>
	</head>
	<body>
		<h1>Create a new Quest</h1>
		<div id="new-quest-form">
			<form action="/quests/new" method="POST">
			</form>
		</div>
	</body>
	</html>
	
<% } %>