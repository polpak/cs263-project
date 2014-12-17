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
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Questor - The world is your RPG</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </head>
  <body role="document">
    <nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="/">Questor</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse navbar-right">
          <ul class="nav navbar-nav">
            <li><a href="/questor/search.jsp">Quests</a></li>
            <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                  Account <b class="caret"></b>
                </a>
                <ul class="dropdown-menu">
                  <li><a href="/user/profile.jsp">Profile</a></li>
                  <li class="divider"></li>
                  <li>
                    <a href="/user/logout.jsp">Logout</a>
                  </li>
                </ul>
              </li>
          </ul>
        </div>
      </div>
    </nav>
 	<div class="container" role="main" style="margin-top:5em">
  <div class="row">
    <div class="col-md-6 col-md-offset-3">
    	<div class="page-header">
		<h1>Quest Details</h1>
		</div>
		<h2 id="quest-title"></h2>
		<p id="quest-description" style="min-height:10em;border:1px solid grey;padding:0 1em">
		</p>
		<p>Reward:<span id="quest-reward"></span>xp</p>
		<p>Expires:<span id="quest-expiration"></span></p>
		<div id="quest-status"></div>
	</div>
	</div>
	</div>
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
				$('#quest-expiration').text((expiration.getMonth()+1) + '-' 
											+ expiration.getDate() + '-' + expiration.getFullYear());
				acceptBtn = '<form id="accept-quest-form"><input type="submit" name="Accept Quest" value="Accept Quest"></form>';
				completeBtn = '<form id="complete-quest-form"><input type="submit" name="Accept Quest" value="Complete Quest"></form>'
				if(data['completed']) {
					$('#quest-status').html('<p>Quest Complete!</p>');
				}
				else if(data["questerKey"]) {
					if(data["questerKey"] != current_user) {
					    $('#quest-status').html('<p>Quest was accepted by ' + data["questerKey"] + '</p>');
					}
					else {
						$('#quest-status').html(completeBtn);
			    		$('#complete-quest-form').submit(function(e)
			    				{

							var questData = {"completed": true};
							
							var jsonData = JSON.stringify(questData);
						    e.preventDefault();
						    
						    var success = function(data, textStatus, jqXHR) {
						    	$('#quest-status').html('<p>Quest Complete!</p>');
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
				}
				else if(data["questMasterKey"] != current_user){
		    		$('#quest-status').html(acceptBtn);
		    		$('#accept-quest-form').submit(function(e)
		    				{

						var questData = {"questerKey": current_user};
						
						var jsonData = JSON.stringify(questData);
					    e.preventDefault();
					    
					    var success = function(data, textStatus, jqXHR) {
					    	$('#quest-status').html(completeBtn);
					    	$('#complete-quest-form').submit(function(e)
				    				{

								var questData = {"completed": true};
								
								var jsonData = JSON.stringify(questData);
							    e.preventDefault();
							    
							    var success = function(data, textStatus, jqXHR) {
							    	$('#quest-status').html('<p>Quest Complete!</p>');
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
	</body>
	</html>
	
<% } %>