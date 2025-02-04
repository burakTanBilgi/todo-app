$(document).ready(function () {
    $("#taskForm").submit(function (event) {
        event.preventDefault();

        var taskName = $("#taskName").val();
        var taskDescription = $("#taskDescription").val();

        console.log("Sending request to add task...");
        
        $.ajax({
            url: "todo.asp?action=add",
            type: "POST",
            data: { taskName: taskName, taskDescription: taskDescription },
            dataType: "json",
            success: function (response) {
                console.log("Server Response:", response);
            },
            error: function (xhr, status, error) {
                console.log("AJAX Error:", status, error);
            }
        });
    });

    $("#loadTasks").click(function () {
        console.log("Sending request to get tasks...");

        $.ajax({
            url: "todo.asp?action=get",
            type: "GET",
            dataType: "json",
            success: function (response) {
                console.log("Server Response:", response);
            },
            error: function (xhr, status, error) {
                console.log("AJAX Error:", status, error);
            }
        });
    });
});
