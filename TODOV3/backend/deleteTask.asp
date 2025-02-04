<!--#include file="dbConnect.asp"-->
<%
Dim taskIdToDelete
taskIdToDelete = Request.Form("taskID")

sql = "DELETE FROM Tasks WHERE taskID = " & taskIdToDelete
conn.Execute sql
%>
