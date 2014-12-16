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
		var url = '/quests/';

	    $.getJSON(url, function(data ) {
			$.each(data, function(i, quest) {
				var expiration = new Date(quest['expiration']);
				$('#search-results').append('<tr>' +
						'<td><a href="/questor/show.jsp?k=' + quest['questKey'] + '">'+ quest['title'] + '</a></td>'
						+ '<td>' + quest['reward'] + '</td>'
						+ '<td>' + expiration.getMonth() + '-' + expiration.getDate() + '-' + expiration.getFullYear() + '</td>'
						+ '<td>' + quest['questMasterKey'] + '</td>'
						+ '</tr>')		
			});
	    });
	    
	});

	</script>
	<link type="text/css" rel="stylesheet" href="/css/main.css"/>
	</head>
	<body>
		<h1>Find a Quest</h1>
		<div id="quest-page" >
		<table id="search-results">
			  	<tr class="header-row"><th>Title</th><th>Reward</th><th>Expires</th><th>Quest Master</th></tr>
		</table>
		</div>
	</body>
	</html>
	
<% } %>