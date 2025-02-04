<%@ Language="VBScript" CodePage="65001" %>
<%
On Error Resume Next
Dim conn, rs, sql
Set sql = Server.CreateObject("ADODB.Command")
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=LAPTOP-NNFULJTO\SQLKODLAB;Initial Catalog=TODODB;User ID=MyUser;Password=MyPassword;"
%>