<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.EntityNotFoundException" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.Transaction" %>
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
		// Check for errors
		ArrayList<String> formErrors = new ArrayList<String>();
		
		if(request.getMethod().equals("POST")) {
			HashMap<String, String> requiredFields = new HashMap<String,String>();
			requiredFields.put("first_name", "First name");
			requiredFields.put("last_name", "Last name");
			requiredFields.put("email_address", "Email address");
			requiredFields.put("password", "Password");
			requiredFields.put("confirm_password", "Password confirmation");
			
			for(String key : requiredFields.keySet()) {
				if(request.getParameter(key) == null || request.getParameter(key).trim().equals("")) {
					String error = String.format("%s cannot be blank.", requiredFields.get(key));
					formErrors.add(error);
				}				
			}
			
			if(formErrors.size()== 0) {
				// valid data checks
				if(!request.getParameter("password").equals(request.getParameter("confirm_password")))
					formErrors.add("Password fields do not match.");
				
				if(request.getParameter("password").contains(" "))
					formErrors.add("Password fields cannot contain spaces.");
				
				if(!request.getParameter("email_address").contains("@"))
					formErrors.add("You must use a valid email address.");
			}
			
			if(formErrors.size()== 0) {
				// No missing or invalid data so...
				String email_address = request.getParameter("email_address").toLowerCase().trim();

				Transaction txn = datastore.beginTransaction();
				try {
				    Key userKey = KeyFactory.createKey("User", email_address);
				    Entity user = datastore.get(userKey);
				    
				    formErrors.add("A user with this email address already exists.");
				} catch (EntityNotFoundException e) {
					Entity user = new Entity("User", email_address);
					for(String prop : requiredFields.keySet()) {
						if(!prop.equals("confirm_password"))
							user.setProperty(prop, request.getParameter(prop).trim());
					}
					datastore.put(user);
					session.setAttribute("email_address", email_address);
				}
				txn.commit();
				
				if(session.getAttribute("email_address") != null)
					response.sendRedirect("/user/profile.jsp");
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
		<div id="signup-form">
			<% if(formErrors.size() != 0) { %>
				<ul class="form-errors">
				<% for(String err: formErrors){ %>
					<li><%=err %></li>
				<% } %>
				</ul>
			<% } %>
			<h3>Signup</h3>
			<form action="/user/signup.jsp" method="POST">
				<span class="first-name-input"><input type="text" name="first_name" value="" placeholder="First Name"></span>
				<span class="last-name-input"><input type="text" name="last_name" value="" placeholder="Last Name"></span>
				<span class="email-address-input"><input type="text" name="email_address" value="" placeholder="Email"></span>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password"></span>
				<span class="password-input"><input type="password" name="confirm_password" value="" placeholder="Confirm Password"></span>
				<span class="signup-submit"><input type="submit" name="Signup" value="Signup"></span>
			</form>
			<p>Already have an account? <a href="/user/login.jsp">Login here</a>.</p>
		</div>
	</body>
	</html>
<%
}
%>