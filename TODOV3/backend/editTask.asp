<!--#include file="dbConnect.asp"-->
<%
Dim taskID, taskName, taskDescription, isCompleted
taskID = Request.Form("taskID")
taskName = Request.Form("taskName")
taskDescription = Request.Form("taskDescription")
isCompleted = Request.Form("IsCompleted")

If isCompleted = "true" Or isCompleted = "1" Then
    isCompleted = 1 
Else
    isCompleted = 0 
End If

sql = "UPDATE Tasks SET TaskName = '" & taskName & "',TaskDescription = '" & taskDescription & "', IsCompleted = " & isCompleted & " WHERE TaskID = " & taskID
conn.Execute sql
%>
