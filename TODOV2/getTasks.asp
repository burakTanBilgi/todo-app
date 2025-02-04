<!--#include file="todo.asp"-->
<%
Response.ContentType = "application/json"
Dim rs, sql

sql = "SELECT * FROM Tasks ORDER BY TaskID DESC"

Set rs = conn.Execute(sql)

' Check for errors
'If Err.Number <> 0 Then
'    Response.Write "{""status"": ""error"", ""message"": ""Error retrieving tasks: " & Err.Description & """}"
'    Response.End
'End If

' Convert result to JSON
Dim tasks
tasks = "["
Do While Not rs.EOF
    tasks = tasks & "{""id"": """ & rs("TaskID") & """, ""task"": """ & rs("TaskName") & """}"
    rs.MoveNext
    If Not rs.EOF Then tasks = tasks & ","
Loop
tasks = tasks & "]"

rs.Close
Set rs = Nothing

Response.Write tasks
%>
