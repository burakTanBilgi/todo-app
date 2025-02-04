<!--#include file="dbConnect.asp"-->
<%
Response.Charset = "UTF-8"

Set rs = conn.Execute("SELECT TaskID, TaskName, TaskDescription, IsCompleted FROM Tasks")

dim taskID, taskName, taskDescription, isCompleted, taskJson, firstTask

taskJson = "{""data"":["
firstTask = True
Do While Not rs.EOF
    taskID = rs("TaskID")
    taskName = rs("TaskName")
    taskDescription = rs("TaskDescription")
    isCompleted = rs("IsCompleted")
    
    ' If it's not the first task, add a comma to separate tasks
    If Not firstTask Then
        taskJson = taskJson & ","
    End If
    
    taskJson = taskJson & "{"
    taskJson = taskJson & """TaskID"": " & taskID & ","
    taskJson = taskJson & """TaskName"": """ & taskName & ""","
    taskJson = taskJson & """TaskDescription"": """ & taskDescription & ""","
    taskJson = taskJson & """IsCompleted"": """ & isCompleted & """"
    taskJson = taskJson & "}"
    
    firstTask = False
    rs.MoveNext
Loop
taskJson = taskJson & "]}"

Response.ContentType = "application/json"
Response.Write taskJson
Response.End

rs.Close
conn.Close
Set rs = Nothing
%>