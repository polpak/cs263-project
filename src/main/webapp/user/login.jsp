<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.EntityNotFoundException" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>

<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	if(session.getAttribute("email_address") != null)
		response.sendRedirect("/user/profile.jsp");
	else {
		ArrayList<String> formErrors = new ArrayList<String>();
		
		if(request.getMethod().equals("POST")) {
			HashMap<String, String> requiredFields = new HashMap<String,String>();
			requiredFields.put("email_address", "Email address");
			requiredFields.put("password", "Password");
		
		
			for(String key : requiredFields.keySet()) {
				if(request.getParameter(key) == null || request.getParameter(key).trim().equals("")) {
					String error = String.format("%s cannot be blank.", requiredFields.get(key));
					formErrors.add(error);
				}				
			}
			
			String email_address = request.getParameter("email_address").toLowerCase().trim();
			
			try {
			    Key userKey = KeyFactory.createKey("User", email_address);
			    Entity user = datastore.get(userKey);
			    String pass = (String)user.getProperty("password");
			    if(!pass.equals(request.getParameter("password")))
			    	formErrors.add("Email/Password combination is invalid.");
			    else {
			    	session.setAttribute("email_address", email_address);
			    	response.sendRedirect("/user/profile.jsp");
			    }
			    			
			} catch (EntityNotFoundException e) {
				formErrors.add("Email/Password combination is invalid.");
			}
		}
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
		<div id="login-form">
			<% if(formErrors.size() != 0) { %>
				<ul class="form-errors">
				<% for(String err: formErrors){ %>
					<li><%=err %></li>
				<% } %>
				</ul>
			<% } %>
			<h3>Login</h3>
			<form action="/user/login.jsp" method="POST">
				<span class="email-input"><input type="text" name="email_address" value="" placeholder="Email"></span>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password"></span>
				<span class="login-submit"><input type="submit" name="Login" value="Login"></span>
			</form>
			<p>Don't have an account? <a href="/user/signup.jsp">Signup here</a>.</p>
		</div>
	</body>
	</html>
<%
}
%>