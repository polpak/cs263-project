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

	function getUrlParameter(sParam)
	{
	    var sPageURL = window.location.search.substring(1);
	    var sURLVariables = sPageURL.split('&');
	    for (var i = 0; i < sURLVariables.length; i++) 
	    {
	        var sParameterName = sURLVariables[i].split('=');
	        if (sParameterName[0] == sParam) 
	        {
	            return sParameterName[1];
	        }
	    }
	}

	$( document ).ready(function() {
		var questKey = Number(getUrlParameter('k'));
		var url = '/quests/'+ questKey;
		var current_user = "<%= user.getUserKey()%>";

	    $.getJSON(url, function( data ) {
				$('#quest-title').text(data["title"]);
				$('#quest-description').text(data["description"]);
				$('#quest-reward').text(data["reward"]);
				expiration = new Date(data['expiration']);
				$('#quest-expiration').text(expiration.getMonth() + '-' 
											+ expiration.getDate() + '-' + expiration.getFullYear());
				
				if(data["questerKey"]) {
					if(data["questerKey"] != current_user) {
					    $('#quest-status').html('<p>Quest was accepted by ' + data["questerKey"] + '</p>');
					}
					else {
						$('#quest-status').html('<p>You have accepted this quest</p>');
					}
				}
				else if(data["questMasterKey"] != current_user){
		    		$('#quest-status').html('<form id="accept-quest-form"><input type="submit" name="Accept Quest" value="Accept Quest"></form>');
		    		$('#accept-quest-form').submit(function(e)
		    				{

						var questData = {"questerKey": current_user};
						
						var jsonData = JSON.stringify(questData);
					    e.preventDefault();
					    
					    var success = function(data, textStatus, jqXHR) {
					    	$('#quest-status').html('<p>Quest Accepted!</p>');
					    }
					    
					    error = function(data, textStatus, jqXHR) {
					    	alert("There was an error accepting the quest");
					    }
					    
					    $.ajax({
					    		type: "PUT",
								url: url,
								data: jsonData,
								success: success,
								contentType: "application/json"
								});
					});
		    	}
		    	else {
		    		$('#quest-status').html('<p>Status: Waiting for Quester</p>');
		    	}
	    });
	    
	    
	    
	});
	</script>
	<link type="text/css" rel="stylesheet" href="/css/main.css"/>
	</head>
	<body>
		<h1>Quest Details</h1>
		<h2 id="quest-title"></h2>
		<p id="quest-description">
		</p>
		<p>Reward:<span id="quest-reward"></span>xp</p>
		<p>Expires:<span id="quest-expiration"></span></p>
		<div id="quest-status"></div>
	</body>
	</html>
	
<% } %>