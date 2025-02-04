$(document).ready(function () {
    $("#task-grid").kendoGrid({
        dataSource: {
            transport: {
                read: {
                    url: "backend/todo.asp?action=getTasks",
                    dataType: "json"
                },
                update: {
                    url: "backend/todo.asp?action=editTask",
                    type: "POST"
                },
                create: {
                    url: "backend/todo.asp?action=addTask",
                    type: "POST",
                    dataType: "json",
                    success: function() {
                        $("#task-grid").data("kendoGrid").dataSource.read();
                    }
                },
                destroy: {
                    url: "backend/todo.asp?action=deleteTask",
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