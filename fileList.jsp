<%@ page contentType="text/html; charset=utf-8" %>

<%@ page import="java.io.File" %>

<%
	File path = new File("C:/10");
		
	String[] filesNm = path.list();
		
	for(int i=0; i < filesNm.length; i++ ){
%>		
		<a href="/excelData.jsp?excel=<%=filesNm[i]%>"><%=filesNm[i]%></a>
<%
	}
%>