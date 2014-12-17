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
<%@ page import="java.util.Calendar" %>

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
		<div id="user-profile" class="row">
		<div class="col-sm-4">
	  		<img id="user-avatar" height="100" width="66" src="/user/avatar">
	  	<form action="<%= blobstoreService.createUploadUrl("/user/avatar") %>" method="post" enctype="multipart/form-data">
            <input type="file" name="user_avatar">
            <input type="submit" value="Update Avatar">
        </form>
        </div>
        <div class="col-sm-4">
        	<div class="page-header">
        	<h1>
	  		<%= user.getFirstName() %> <%= user.getLastName() %>
			</h1>
	  		</div>
	  		<h2>Exp Points: <%= user.getExperiencePoints() %></h2>
	  	</div>
	  	</div>
	  	<div class="row">
	  	<div class="quest-container col-md-6">
	  		  <div class="page-header">
		        <h3>Posted Quests</h3>
		      </div>
	  		<% if(!posted_quests.isEmpty()) { %>

			  	<table id="posted-quests" class="table table-striped">
			  	<thead>
			  			<tr class="header-row"><th>Title</th><th>Reward</th><th>Expires</th><th>Status</th></tr>
			  	</thead>
			  	<tbody>
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
			  				  				Calendar c = Calendar.getInstance();
			  				  				c.setTime(quest.getExpiration());
			  				  				String expirationString = String.format("%d-%02d-%d", 
			  				  														c.get(Calendar.MONTH)+1, 
			  				  														c.get(Calendar.DAY_OF_MONTH), 
			  				  														c.get(Calendar.YEAR));
			  			%>
			  				<tr>
			  					<td><a href="/questor/show.jsp?k=<%=quest.getQuestKey()%>"><%=quest.getTitle()%></a></td>
			  					<td><%=quest.getReward()%></td>
			  					<td><%=expirationString %></td>
			  					<td><%=status%></td>
			  				</tr>
			  		<%
			  			}
			  		%>
			  	</tbody>
			  	</table>
		  	<%
		  		}
		  	%>
	  	</div>
	  	<div class="quest-container col-md-6">
	  		<div class="page-header">
		        <h3>Accepted Quests</h3>
		    </div>
		  	<%
		  		if(!accepted_quests.isEmpty()) {
		  	%>
			  	<table id="accepted-quests" class="table table-striped">
			  	<thead>
			  			<tr class="header-row"><th>Title</th><th>Reward</th><th>Expiration</th><th>Status</th></tr>
			  	</thead>
			  	<tbody>
			  			<%
			  				for(Quest quest : accepted_quests){
			  				  				String status = "In progress";
			  				  				
			  				  				if(quest.isCompleted()) {
			  				  					status = "Complete";
			  				  				}
			  				  				else if(quest.getExpiration().before(new Date())) {
			  				  					status = "Expired";
			  				  				}
			  				  				Calendar c = Calendar.getInstance();
			  				  				c.setTime(quest.getExpiration());
			  				  				String expirationString = String.format("%d-%02d-%d", 
			  				  														c.get(Calendar.MONTH)+1, 
			  				  														c.get(Calendar.DAY_OF_MONTH), 
			  				  														c.get(Calendar.YEAR));
			  			%>
			  				<tr>
			  					<td><a href="/questor/show.jsp?k=<%=quest.getQuestKey()%>"><%=quest.getTitle()%></a></td>
			  					<td><%=quest.getReward()%></td>
			  					<td><%=expirationString%></td>
			  					<td><%=status %></td>
			  				</tr>
			  		<% } %>
				</tbody>
			  	</table>
			<% } %>
	  	</div>
  		</div>
  		<div class="row">
  			<div class="col-md-6">
				<a href="/questor/new.jsp">Create a new quest!</a>
  			</div>
  			<div class="col-md-6">
  				<a href="/questor/search.jsp">Find a quest!</a>
  			</div>
  		</div>
	</div>
	</body>
	</html>
	
<% } %>