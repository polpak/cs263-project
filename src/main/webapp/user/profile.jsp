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
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	if(session.getAttribute("email_address") == null) {
		response.sendRedirect("/user/login.jsp");
	} else { 
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    Key userKey = KeyFactory.createKey("User", (String)session.getAttribute("email_address"));
	    Entity user = datastore.get(userKey);
	    
	    Query posted_quests_query = new Query("Quest").setAncestor(userKey);	     
	    List<Quest> posted_quests = Quest.fromQuery(datastore, posted_quests_query);
	    
	    Query accepted_quests_query = new Query("AcceptedQuests").setAncestor(userKey).addSort("expires", Query.SortDirection.ASCENDING);
	    List<Entity> accepted_quest_entities = datastore.prepare(accepted_quests_query).asList(FetchOptions.Builder.withDefaults());
	    List<String> accepted_keys = new ArrayList<String>();
	    
	    for(Entity e : accepted_quest_entities) {
	    	accepted_keys.add(e.getProperty("quest_key");
	    }
	    List<Quest> accepted_quests = Quest.fromDatastore(datastore, accepted_keys);
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
	  		<span id="name"><%= user.getProperty("first_name") %> <%= user.getProperty("last_name") %></span>
	  	</div>
	  	<div class="quest-container">
	  		<% if(!posted_quests.isEmpty()) { %>
			  	<table id="posted-quests">
			  			<tr class="header-row"><th>Title</th><th>Roles filled<th><th>Expiration</th><th>Status</th></tr>
			  			<% for(Entity quest : posted_quests){
			  				String title = (String)quest.getProperty("title");
			  				Key questKey = quest.getKey();
			  				Query quest_role_query = new Query("QuestRole").setAncestor(questKey);
			  				List<Entity> quest_roles = datastore.prepare(quest_role_query).asList(FetchOptions.Builder.withDefaults());
			  				
			  				int role_count = 0;
			  				int accepted_count = 0;
			  				int completed_count = 0;
			  				
			  				for(Entity role : quest_roles) {
			  					role_count += 1;
			  					if(role.hasProperty("quester")){
			  						accepted_count += 1;
			  						if(role.hasProperty("completed"))
			  							completed_count += 1;
			  					}
			  				}
			  				
			  				String rolesFilled = String.format("%d/%d", role_count, accepted_count);
			  				Date expiration = (Date)quest.getProperty("expires");
			  				
			  				String status = "Looking for more";
			  				if(role_count == accepted_count) {
			  					status = "In progress";
			  					if(completed_count == role_count)
			  						status = "Quest complete!";
			  				}
			  				
			  			%>
			  				<tr>
			  					<td><a href="/quests/show.jsp?k=<%=quest.getKey()%>"><%=title%></a></td>
			  					<td><%=rolesFilled%></td>
			  					<td><%=expiration %></td>
			  					<td><%=status %></td>
			  				</tr>
			  		<% } %>
			  	</table>
		  	<% } %>
		  	<a href="/quests/new.jsp">Create a new quest!</a>
	  	</div>
	  	<div class="quest-container">
		  	<% if(!accepted_quests.isEmpty()) { %>
			  	<table id="accepted-quests">
			  			<tr class="header-row"><th>Title</th><th>Role<th><th>Expiration</th><th>Status</th></tr>
			  			<% for(Entity questRole : accepted_quests) { 
			  				Key acceptedQuestKey = (Key)questRole.getProperty("questKey");
			  				Entity quest = datastore.get(acceptedQuestKey);
			  				String title = (String)quest.getProperty("title");
			  				String role = (String)questRole.getProperty("name");
			  				Date expiration = (Date)quest.getProperty("expires");
			  				String status = "Accepted";
			  				if(questRole.hasProperty("completed"))
			  					status = "Completed";
			  				
			  			%>
			  				<tr>
			  					<td><a href="/quests/show.jsp?k=<%=acceptedQuestKey%>"><%=title%></a></td>
			  					<td><%=role%></td>
			  					<td><%=expiration %></td>
			  					<td><%=status %></td>
			  				</tr>
			  			
			  			<% } %>
			  	</table>
			<% } %>
			<a href="/quests/search.jsp">Find a quest!</a>
	  	</div>
	</body>
	</html>
	
<% } %>