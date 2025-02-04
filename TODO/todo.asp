<%@ Language=VBScript %>
<%
On Error Resume Next
' Database connection setup
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=LAPTOP-NNFULJTO\SQLKODLAB;Initial Catalog=TODODB;User ID=MyUser;Password=MyPassword;"

'  Perform CRUD operations
Dim action, taskID, taskName, taskDescription

action = Request.Form("action")
taskID = Request.Form("taskID")
taskName = Request.Form("taskName")
taskDescription = Request.Form("taskDescription")

' Add a new task
If action = "add" Then
    Dim addSQL
    addSQL = "INSERT INTO Tasks (TaskName, TaskDescription) VALUES (?, ?)"
    ExecuteSQL conn, addSQL, Array(taskName, taskDescription)
    Response.Redirect "todo.asp"
End If

If action = "search" Then
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conn
    cmd.CommandText = "SELECT * FROM Tasks WHERE TaskName LIKE ?"

    cmd.Parameters.Append cmd.CreateParameter("@taskName", 200, 1, 255, "%" & taskName & "%")
    status = 1
    Set rs = cmd.Execute()
End If

' Update an existing task
If action = "update" Then
    Dim updateSQL
    updateSQL = "UPDATE Tasks SET TaskName = ?, TaskDescription = ? WHERE TaskID = ?"
    ExecuteSQL conn, updateSQL, Array(taskName, taskDescription, taskID)
    Response.Redirect "todo.asp"
End If

' Delete a task
If action = "delete" Then
    Dim deleteSQL
    deleteSQL = "DELETE FROM Tasks WHERE TaskID = ?"
    ExecuteSQL conn, deleteSQL, Array(taskID)
    Response.Redirect "todo.asp"
End If

' Mark a task as completed
If action = "complete" Then

    Set cmd = Server.CreateObject("ADODB.Command")
    
    ' Setup the stored procedure
    cmd.ActiveConnection = conn
    cmd.CommandText = "MarkTaskAsCompleted" ' Stored procedure name
    cmd.CommandType = 4 ' 4 = Stored Procedure
    
    ' Add parameters to the stored procedure
    cmd.Parameters.Append cmd.CreateParameter("@TaskID", 3, 1, 4, taskID) ' 3 = adInteger, 1 = adParamInput, 4 = adNumeric
    
    ' Execute the stored procedure
    cmd.Execute
    
    ' Clean up
    Set cmd = Nothing
    
    ' Redirect to the same page to refresh the tasks
    Response.Redirect "todo.asp"
End If



' Retrieve all tasks
Function GetTasks(orderByColumn, orderDirection)
    Dim tasks, sqlQuery

    ' Build the SQL query dynamically based on the parameters
    sqlQuery = "SELECT * FROM Tasks ORDER BY " & orderByColumn

    ' Add DESC to the query if the orderDirection is 0 (descending order)
    If orderDirection = "Descending" Then
        sqlQuery = sqlQuery & " DESC"
    End If

    ' Check if status is 1 and use GetRows if applicable
    If status = 1 Then
        tasks = rs.GetRows()
        GetTasks = tasks
        Set rs = Nothing
        Exit Function
    End If

    ' Execute the SQL query
    Set rs = conn.Execute(sqlQuery)
    
    ' Get the tasks using GetRows
    tasks = rs.GetRows()

    ' Close the recordset and clean up
    rs.Close
    Set rs = Nothing

    ' Return the tasks
    GetTasks = tasks
End Function

    


' Helper function to execute parameterized queries
Sub ExecuteSQL(conn, sql, params)
    Dim cmd, i
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conn
    cmd.CommandText = sql
    cmd.CommandType = 1 ' adCmdText
    For i = 0 To UBound(params)
        cmd.Parameters.Append cmd.CreateParameter("@p" & i + 1, 200, 1, 255, params(i)) ' adVarChar
    Next
    cmd.Execute
    Set cmd = Nothing
End Sub


'ORDER Direction

If Session("orderDirection") = "" Then
    Session("orderDirection") = "Ascending"
    Session("orderValue") = "TaskID"
End If

' Check if the form has been submitted
If Request.Form("orderDirectionChange") <> "" Then
    Session("orderDirection") = Request.Form("orderDirectionChange")
End If

If Request.Form("orderValueChange") <> "" Then
    Session("orderValue") = Request.Form("orderValueChange")
End If   
    
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TODO List with Database</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        h1 {
            color: #444;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input[type="text"],
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        .form-group textarea {
            resize: vertical;
            height: 100px;
        }
        .btn {
            background-color: #28a745;
            color: white;
            border: none;
            margin-bottom: 5px;
            width: 100px;
            height: 40px;
            font-size: 16px;
            border-radius: 12px;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #218838;
        }
        .btn-danger {
            background-color: #dc3545;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        .btn-secondary {
            margin-left: 10px;
            margin-bottom: 25px;
            background-color: #6c757d;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f8f9fa;
        }
        .completed {
            text-decoration: line-through;
            color: #6c757d;
        }
        .actions {
            display: inline;
            gap: 10px;
        }
        .buttons {
            
        }
        .update-form {
        display: none; /* Hide the form by default */
        }

        .update-form.edit-mode {
            display: block; /* Show the form when in edit mode */
        }

        .form-group {
            margin-bottom: 10px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }

        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }

        .btn-cancel {
            background-color: #6c757d;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }

        .btn-cancel:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>TODO List</h1>

        <!-- Form to add or update a task -->
        <form method="post">
            <input type="hidden" name="action" value="add" />
            <div class="form-group">
                <label for="taskName">Task Name:</label>
                <input type="text" name="taskName" placeholder="Enter task name" required />
            </div>
            <div class="form-group">
                <label for="taskDescription">Task Description:</label>
                <textarea name="taskDescription" placeholder="Enter task description"></textarea>
            </div>
            <button type="submit" class="btn">Add Task</button>
        </form>

        <form method="post">
            <input type="hidden" name="action" value="search" />
            <div class="form-group">
                <label for="taskName">Search:</label>
                <input type="text" name="taskName" placeholder="Search task name" required />
            </div>
            <button type="submit" class="btn">Search</button>
        </form>

        <!-- Display all tasks -->
        <h2>Task List:</h2>
        <table>
            <thead>
                    <tr>
                        <th>
                            <form method="post">
                                <input type="hidden" name="orderValueChange" value="TaskID">
                                <button type="submit" class="btn btn-secondary">ID</button>
                            </form>
                        </th>
                        <th>
                            <form method="post">
                                <input type="hidden" name="orderValueChange" value="TaskName">
                                <button type="submit" class="btn btn-secondary">Name</button>
                            </form>
                        </th>
                        <th>
                            <form method="post">
                                <input type="hidden" name="orderValueChange" value="TaskDescription">
                                <button type="submit" class="btn btn-secondary">Description</button>
                            </form>
                        </th>
                        <th>Completed</th>
                        <th>Actions</th>
                        <th>
                            <form method="post">
                                <input type="hidden" name="orderDirectionChange" value="Ascending">
                                <button type="submit" class="btn btn-secondary">Ascending</button>
                            </form>
                            <form method="post">
                                <input type="hidden" name="orderDirectionChange" value="Descending">
                                <button type="submit" class="btn btn-secondary">Descending</button>
                            </form>
                        </th>
                    </tr>
                    
            </thead>
            <tbody>
                <%
                Dim tasks, i
                'tasks = GetTasks()
                tasks = GetTasks(Session("orderValue"), Session("orderDirection"))
                For i = 0 To UBound(tasks, 2)
                    Dim isCompleted
                    isCompleted = CBool(tasks(3, i))
                %>
                <tr class="<% If isCompleted Then Response.Write("completed") %>">
                    <td><%=tasks(0, i)%></td>
                    <td><%=tasks(1, i)%></td>
                    <td><%=tasks(2, i)%></td>
                    <td><% If isCompleted Then Response.Write("Yes") Else Response.Write("No") %></td>
                    <td class="actions">
                        <!-- Update form -->
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="action" value="update" />
                            <input type="hidden" name="taskID" value="<%=tasks(0, i)%>" />
                            <input type="text" name="taskName" value="<%=tasks(1, i)%>" required />
                            <textarea name="taskDescription"><%=tasks(2, i)%></textarea>
                            <button type="submit" class="btn btn-secondary">Update</button>
                        </form>
                        </td>
                        <td class="buttons">
                        <!-- Mark as completed form -->
                        <% If Not isCompleted Then %>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="action" value="complete" />
                            <input type="hidden" name="taskID" value="<%=tasks(0, i)%>" />
                            <button type="submit" class="btn">Complete</button>
                        </form>
                        <% End If %>

                        <!-- Delete form -->
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete" />
                            <input type="hidden" name="taskID" value="<%=tasks(0, i)%>" />
                            <button type="submit" class="btn btn-danger">Delete</button>
                        </form>
                    </td>
                </tr>
                <% Next %>
            </tbody>
        </table>
    </div>
</body>
</html>