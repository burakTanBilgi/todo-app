<%@ Language="VBScript" CodePage="65001" %>
<%
On Error Resume Next
Dim conn, rs, sql, action, taskID, taskName, taskDescription, isCompleted, taskJson, firstTask
Set sql = Server.CreateObject("ADODB.Command")
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=LAPTOP-NNFULJTO\SQLKODLAB;Initial Catalog=TODODB;User ID=MyUser;Password=MyPassword;"

taskID = Request.Form("taskID")
taskName = Request.Form("taskName")
taskDescription = Request.Form("taskDescription")
isCompleted = Request.Form("IsCompleted")

action = Request.QueryString("action")

Select Case action
    Case "addTask"

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
        Response.End
    Case "getTasks"
        Response.Charset = "UTF-8"

        Set rs = conn.Execute("SELECT TaskID, TaskName, TaskDescription, IsCompleted FROM Tasks")

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

    Case "deleteTask"

        sql = "DELETE FROM Tasks WHERE taskID = " & taskID
        conn.Execute sql

    Case "editTask"

        If isCompleted = "true" Or isCompleted = "1" Then
            isCompleted = 1 
        Else
            isCompleted = 0 
        End If

        sql = "UPDATE Tasks SET TaskName = '" & taskName & "',TaskDescription = '" & taskDescription & "', IsCompleted = " & isCompleted & " WHERE TaskID = " & taskID
        conn.Execute sql
End Select
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Kendo UI Grid Example</title>
    <link rel="stylesheet" href="https://kendo.cdn.telerik.com/themes/10.0.1/classic/classic-uniform.css" />  
    <style>
        h2 {
            text-align: center;
        }

        .k-grid-toolbar {
        text-align: center;
        }

        .k-grid-toolbar .k-button {
        margin: 0 auto;
        display: inline-block;
        }

        .k-edit-form-container {
            overflow-y: hidden !important;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://kendo.cdn.telerik.com/2024.4.1112/js/kendo.all.min.js"></script>
    <script>
        $(document).ready(function () {
            $("#task-grid").kendoGrid({
                dataSource: {
                    transport: {
                        read: {
                            url: "todo.asp?action=getTasks",
                            dataType: "json"
                        },
                        update: {
                            url: "todo.asp?action=editTask",
                            type: "POST"
                        },
                        create: {
                            url: "todo.asp?action=addTask",
                            type: "POST",
                            dataType: "json",
                            success: function() {
                                $("#task-grid").data("kendoGrid").dataSource.read();
                            }
                        },
                        destroy: {
                            url: "todo.asp?action=deleteTask",
                            type: "POST"
                        }
                    }, 
                    schema: {
                        data: "data",
                        model: {
                            id: "TaskID",  
                            fields: {
                                TaskID: { type: "number" , editable: false},  
                                TaskName: { type: "string", editable: true}, 
                                TaskDescription: { type: "string", editable: true},  
                                IsCompleted: { type: "boolean", editable: true } 
                            }
                        }
                    },
                    pageSize: 10 
                },
                toolbar: [
                    { name: "create", text: "Add Task" }
                ],
                scrollable: false,
                pageable: true,  
                sortable: true,  
                filterable: true, 
                editable: "popup",
                columns: [
                    { field: "TaskID", title: "ID", width: 50 },
                    { field: "TaskName", title: "Task Name" },  
                    { field: "TaskDescription", title: "Description" },  
                    { field: "IsCompleted", title: "Completed", width: 100, template: "#= IsCompleted ? '✔️' : '❌' #" },
                    { command: ["edit", "destroy"], title: "Actions", width: 150 }
                ]
            });
        });
</script>
</head>
<body>
    <div id="app">
        <h2>Task Manager</h2>
        <div id="task-grid"></div>
    </div>
</body>
</html>