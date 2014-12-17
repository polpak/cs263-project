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
		User user = null;
		try {
			user = User.fromEmailAddress((String)session.getAttribute("email_address"));
		} catch(EntityNotFoundException e) {
			session.removeAttribute("email_address");
			response.sendRedirect("user/login.jsp");
			return;
		}

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
 		<div class="page-header">
		<h1>Find a Quest</h1>
		</div>
		<div id="quest-page" >
		<table id="search-results"  class="table table-striped">
		<thead>
			  	<tr class="header-row"><th>Title</th><th>Reward</th><th>Expires</th><th>Quest Master</th></tr>
		</thead>
		<tbody>
		</tbody>
		</table>
		</div>
	</div>
	<script type="text/javascript">

	$( document ).ready(function() {
		var url = '/quests/';

	    $.getJSON(url, function(data ) {
			$.each(data, function(i, quest) {
				var expiration = new Date(quest['expiration']);
				$('#search-results>tbody').append('<tr>' +
						'<td><a href="/questor/show.jsp?k=' + quest['questKey'] + '">'+ quest['title'] + '</a></td>'
						+ '<td>' + quest['reward'] + '</td>'
						+ '<td>' + (expiration.getMonth() + 1) + '-' + expiration.getDate() + '-' + expiration.getFullYear() + '</td>'
						+ '<td>' + quest['questMasterKey'] + '</td>'
						+ '</tr>')		
			});
	    });
	    
	});

	</script>
	</body>
	</html>
	
<% } %>