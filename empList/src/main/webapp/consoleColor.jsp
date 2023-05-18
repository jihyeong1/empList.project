<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
//font color
System.out.println("\u001B[31mhello\u001B[0m");
System.out.println("hello");
System.out.println("\u001B[32mhello\u001B[0m");

//background color
System.out.println("\u001B[41mhello\u001B[0m");
System.out.println("hello");
System.out.println("\u001B[47mhello\u001B[0m");

// final 변수(상수)를 사용하여 가독성을 높임
final String RESET = "\u001B[0m"; 
final String RED = "\u001B[31m";
final String BG_RED = "\u001B[41m";

System.out.println(RED+"hello"+RESET);
System.out.println(BG_RED+"hello"+RESET);
%>
