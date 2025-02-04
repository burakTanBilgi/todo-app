<%
Response.AddHeader "Access-Control-Allow-Origin", "*"

Dim action
action = Request.QueryString("action")

Select Case action
    Case "addTask"
        Server.Execute("addTask.asp")
    Case "getTasks"
        Server.Execute("getTasks.asp")
    Case "deleteTask"
        Server.Execute("deleteTask.asp")
    Case "editTask"
        Server.Execute("editTask.asp")
    Case Else
        Response.Write "{""status"": ""error"", ""message"": ""Invalid action""}"
End Select
%>