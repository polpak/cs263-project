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
 	<div class="container" role="main" style="margin-top:5em">
		<div id="login-form">
			<% if(formErrors.size() != 0) { %>
				<ul class="form-errors">
				<% for(String err: formErrors){ %>
					<li><%=err %></li>
				<% } %>
				</ul>
			<% } %>
			<div class="page-header">
			<h3>Login</h3>
			</div>
			<form action="/user/login.jsp" method="POST">
				<span class="email-input"><input type="text" name="email_address" value="" placeholder="Email"></span>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password"></span>
				<span class="login-submit"><input type="submit" name="Login" value="Login"></span>
			</form>
			<p>Don't have an account? <a href="/user/signup.jsp">Signup here</a>.</p>
		</div>
	</div>
	</body>
	</html>
<%
}
%>