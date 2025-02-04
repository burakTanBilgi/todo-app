<%
' Enable error handling
On Error Resume Next

' Database connection setup
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=LAPTOP-NNFULJTO\SQLKODLAB;Initial Catalog=TODODB;User ID=MyUser;Password=MyPassword;"

' Check for errors in connection
If Err.Number <> 0 Then
    Response.Write "{""status"": ""error"", ""message"": ""Database connection failed: " & Err.Description & """}"
    Response.End
End If
%>
<%
Response.ContentType = "application/json"
Response.AddHeader "Access-Control-Allow-Origin", "*"

On Error Resume Next ' Allow error handling

Dim action
action = Request.QueryString("action")

Select Case action
    Case "add"
        Server.Execute("addTask.asp")
    Case "get"
        Server.Execute("getTasks.asp")
    Case Else
        Response.Write "{""status"": ""error"", ""message"": ""Invalid action""}"
End Select

' Check for errors
If Err.Number <> 0 Then
    Response.Write "{""status"": ""error"", ""message"": ""ASP Error: " & Err.Description & """}"
    Err.Clear
End If
%>
