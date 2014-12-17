<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.EntityNotFoundException" %>
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
					user.setProperty("experience_points", new Long(0));
					user.setProperty("email_address", email_address);
					datastore.put(user);
					session.setAttribute("email_address", email_address);
				}
				
				if(session.getAttribute("email_address") != null)
					response.sendRedirect("/user/profile.jsp");
			}
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
            <li><a href="/user/login.jsp">Login</a></li>
            <li><a href="/user/signup.jsp">Signup</a></li>
          </ul>
        </div>
      </div>
    </nav>
 	<div class="row" role="main" style="margin-top:5em">
		<div class="col-md-4 col-md-offset-4" id="signup-form">
			<% if(formErrors.size() != 0) { %>
				<ul class="form-errors">
				<% for(String err: formErrors){ %>
					<li><%=err %></li>
				<% } %>
				</ul>
			<% } %>
			<h3>Signup</h3>
			<form action="/user/signup.jsp" method="POST">
				<span class="first-name-input"><input type="text" name="first_name" value="" placeholder="First Name" required></span><br>
				<span class="last-name-input"><input type="text" name="last_name" value="" placeholder="Last Name" required></span><br>
				<span class="email-address-input"><input type="text" name="email_address" value="" placeholder="Email" required></span><br>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password" required></span><br>
				<span class="password-input"><input type="password" name="confirm_password" value="" placeholder="Confirm Password" required></span><br>
				<span class="signup-submit"><input type="submit" name="Signup" value="Signup"></span>
			</form>
			<p>Already have an account? <a href="/user/login.jsp">Login here</a>.</p>
		</div>
		</div>
	</body>
	</html>
<%
}
%>