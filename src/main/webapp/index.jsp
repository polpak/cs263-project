<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
	if(session.getAttribute("username") != null)
		response.sendRedirect("/user/profile.jsp");
	else {
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
			<h3>Login</h3>
			<form action="/user/login.jsp" method="POST">
				<span class="email-input"><input type="text" name="email_address" value="" placeholder="Email"></span>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password"></span>
				<span class="login-submit"><input type="submit" name="Login" value="Login"></span>
			</form>
		</div>
		<div id="signup-form">
			<h3>Signup</h3>
			<form action="/user/signup.jsp" method="POST">
				<span class="first-name-input"><input type="text" name="first_name" value="" placeholder="First Name"></span>
				<span class="last-name-input"><input type="text" name="last_name" value="" placeholder="Last Name"></span>
				<span class="email-address-input"><input type="text" name="email_address" value="" placeholder="Email"></span>
				<span class="password-input"><input type="password" name="password" value="" placeholder="Password"></span>
				<span class="password-input"><input type="password" name="confirm_password" value="" placeholder="Confirm Password"></span>
				<span class="signup-submit"><input type="submit" name="Signup" value="Signup"></span>
			</form>
		</div>
	</body>
	</html>
<%
}
%>