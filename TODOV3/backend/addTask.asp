<!--#include file="dbConnect.asp"-->
<%
dim taskName, taskDescription
taskName = Request.Form("taskName")
taskDescription = Request.Form("taskDescription")
isCompleted = Request.Form("IsCompleted")

If isCompleted = "true" Or isCompleted = "1" Then
    isCompleted = 1 
Else
    isCompleted = 0 
End If

sql = "INSERT INTO Tasks (TaskName, TaskDescription, IsCompleted) VALUES ('" & taskName & "', '" & taskDescription & "', " & isCompleted & " )"
conn.Execute sql

Set rs = conn.Execute("SELECT SCOPE_IDENTITY() AS NewID")
If Not rs.EOF Then
    newTaskID = rs("NewID")
Else
    newTaskID = 0
End If
Set rs = Nothing

Response.Write "{""status"": ""success"", ""data"": {""TaskID"": " & newTaskID & ", ""TaskName"": """ & Replace(taskName, """", "\""") & """, ""TaskDescription"": """ & Replace(taskDescription, """", "\""") & """, ""IsCompleted"": " & isCompleted & "}}"
%>

