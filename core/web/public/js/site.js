$(document).on('click', '.nav-sidebar li', function() {
   $(".nav-sidebar li").removeClass("active");
   $(this).addClass("active");
});

function setLoadingMessage(string) {
	$("#loading").find("h1").html(string);
};

function setMessage(message, isError) {
    if (isError)
        $("#messages").html('<div class="alert alert-danger fade in"><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><strong>Error: '+message+'</strong></div>');
    else
        $("#messages").html('<div class="alert alert-success fade in"><span class="glyphicon glyphicon-check" aria-hidden="true"></span><strong>Message: '+message+'</strong></div>');
};

function getDesiredIndex(string, type) {
    //type = 0 = bigRow
    //type = 1 = littleRow

    if (type == 0) {
        var firstIndex = string.indexOf("_");
        var firstSubstring = string.substring(firstIndex + 1);
        var secondIndex = firstSubstring.indexOf("_");
        var secondSubstring;
        if (secondIndex == -1) {
            secondSubstring = firstSubstring;
        } else {
            secondSubstring = firstSubstring.substring(0, secondIndex);
        };
        var integer = parseInt(secondSubstring);
        return integer;
    } else if (type == 1) {
        var firstIndex = string.indexOf("_");
        var firstSubstring = string.substring(firstIndex + 1);
        var secondIndex = firstSubstring.indexOf("_");
        var secondSubstring = firstSubstring.substring(secondIndex + 1);
        var integer = parseInt(secondSubstring);
        return integer;
    } else {
        return -1;
    };
}

function deleteCategoryFunction(button) {

    var string = button.attr('id');

    var bigRow = getDesiredIndex(string, 0);

    var bigTable = document.getElementById("bigTable_" + bigRow);

    var everything = document.getElementById("links");

    var text = everything.getElementsByTagName('textarea');

    for (var n = 0; n < text.length; n++) {
        var ID = text[n].id;
        if (ID) {
            if (ID.indexOf("title") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                var littleRow = getDesiredIndex(ID, 1);
                if (lastInt > bigRow) {
                    text[n].id = "title_" + (lastInt - 1).toString() + "_" + littleRow.toString();
                };
            } else if (ID.indexOf("link") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                var littleRow = getDesiredIndex(ID, 1);
                if (lastInt > bigRow) {
                    text[n].id = "link_" + (lastInt - 1).toString() + "_" + littleRow.toString();
                };
            } else if (ID.indexOf("header") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    text[n].id = "header_" + (lastInt - 1).toString();
                };
            };
        };
    };

    var labels = everything.getElementsByTagName('h4');

    for (var m = 0; m < labels.length; m++) {
        var ID = labels[m].id;
        if (ID) {
            if (ID.indexOf("label") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    labels[m].id = "label_" + (lastInt - 1).toString();
                };
            };
        };
    };

    var tables = everything.getElementsByTagName('table');

    for (var o = 0; o < tables.length; o++) {
        var ID = tables[o].id;
        if (ID) {
            if (ID.indexOf("bigTable") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    tables[o].id = "bigTable_" + (lastInt - 1).toString();
                };
            };
        };
    };

    var bodies = everything.getElementsByTagName('tbody');

    for (var p = 0; p < bodies.length; p++) {
        var ID = bodies[p].id;
        if (ID) {
            if (ID.indexOf("table") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    bodies[p].id = "table_" + (lastInt - 1).toString();
                };
            };
        };
    };

    var rows = everything.getElementsByTagName('tr');

    for (var q = 0; q < rows.length; q++) {
        var ID = rows[q].id;
        if (ID) {
            if (ID.indexOf("row") > -1) {
                var lastInt = getDesiredIndex(ID, 0);
                var littleRow = getDesiredIndex(ID, 1);
                if (lastInt > bigRow) {
                    rows[q].id = "row_" + (lastInt - 1).toString() + "_" + littleRow.toString();
                };
            };
        };
    };

    var hold = everything.getElementsByTagName('td');

    for (var r = 0; r < hold.length; r++) {
        var ID = hold[r].id;
        if (ID) {
            if (ID.indexOf("box") > -1) {
                var lastInt = getDesiredIndex(ID, 0);
                var littleRow = getDesiredIndex(ID, 1);
                if (lastInt > bigRow) {
                    hold[r].id = "box_" + (lastInt - 1).toString() + "_" + littleRow.toString();
                };
            };
        };
    };

    var buttons = everything.getElementsByTagName('input');

    for (var s = 0; s < buttons.length; s++) {
        var ID = buttons[s].id;
        if (ID) {
            if (ID.indexOf("deleteCategory") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    buttons[s].id = "deleteCategory_" + (lastInt - 1).toString();
                };
            } else if (ID.indexOf("delete") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                var littleRow = getDesiredIndex(ID, 1);
                if (lastInt > bigRow) {
                    buttons[s].id = "delete_" + (lastInt - 1).toString() + "_" + littleRow.toString();
                };
            } else if (ID.indexOf("add") == 0) {
                var lastInt = getDesiredIndex(ID, 0);
                if (lastInt > bigRow) {
                    buttons[s].id = "add_" + (lastInt - 1).toString();
                };
            };
        };
    };

    var bigHeader = document.getElementById("header_" + bigRow);
    var bigText = document.getElementById("label_" + bigRow);
    var theButton = document.getElementById("deleteCategory_" + bigRow);
    bigTable.parentNode.removeChild(bigTable);
    bigHeader.parentNode.removeChild(bigHeader);
    bigText.parentNode.removeChild(bigText);
    theButton.parentNode.removeChild(theButton);
}

function addCategoryFunction() {

    var theButton = document.getElementById("addCategory");

    theButton.parentNode.removeChild(theButton);

    var bigDiv = document.getElementById("links");

    var count = bigDiv.getElementsByTagName('table').length;

    var button = document.createElement("INPUT");
    button.type = "button";
    button.className = "btn btn-lg btn-primary deleteCategory";
    button.value = "Delete Category";
    button.name = count;
    button.id = "deleteCategory_" + count;
    button.style.float = "right";
    button.style.backgroundColor = "red";
    button.style.borderColor = "red";
    bigDiv.appendChild(button);

    var label = document.createElement("H4");
    label.innerHTML = "Category Name";
    label.style.float = "left";
    label.style.marginRight = "10px";
    label.id = "label_" + count;
    bigDiv.appendChild(label);

    var header = document.createElement("TEXTAREA");
    header.class = "form-control";
    header.style.display = "block";
    header.id = "header_" + count;
    header.width = "33%";
    header.display = "block";
    header.style.marginBottom = "10px";
    bigDiv.appendChild(header);

    var table = document.createElement("TABLE");
    table.id = "bigTable_" + count;

    var tableBody = document.createElement("TBODY");

    tableBody.id = "table_" + count;

    table.appendChild(tableBody);
    table.className = "table table-striped";

    var heading = new Array();
    heading[0] = "Link Title";
    heading[1] = "Hyperlink";
    heading[2] = "Action";

    //TABLE COLUMNS

    var tr = document.createElement("TR");
    tableBody.appendChild(tr);

    for (var k = 0; k < heading.length; k++) {
        var th = document.createElement("TH");
        if (k < 2) {
            th.width = "40%";
        } else {
            th.width = "20%";
        };
        th.appendChild(document.createTextNode(heading[k]));
        tr.appendChild(th);
    };

    var tr = document.createElement("TR");
    tr.id = "row_" + count + "_" + 0;

    var tdOne = document.createElement("TD");

    var titleTextArea = document.createElement("TEXTAREA");
    titleTextArea.class = "form-control";
    titleTextArea.style.display = "block";
    titleTextArea.style.width = "100%";
    titleTextArea.style.overflowY = "scroll";
    titleTextArea.style.resize = "none";
    titleTextArea.id = "title_" + count + "_" + 0;
    tdOne.appendChild(titleTextArea);
    tr.appendChild(tdOne);

    var tdOne = document.createElement("TD");

    var linkTextArea = document.createElement("TEXTAREA");
    linkTextArea.class = "form-control";
    linkTextArea.style.display = "block";
    linkTextArea.style.width = "100%";
    linkTextArea.style.overflowY = "scroll";
    linkTextArea.style.resize = "none";
    linkTextArea.id = "link_" + count + "_" + 0;
    tdOne.appendChild(linkTextArea);
    tr.appendChild(tdOne);

    var tdOne = document.createElement("TD");
    tdOne.id = "box_" + count + "_" + 0;

    var button = document.createElement("INPUT");
    button.type = "button";
    button.className = "btn btn-lg btn-primary deleteLink";
    button.value = "Delete";
    button.name = count;
    button.id = "delete_" + count + "_" + 0;
    button.style.marginRight = "10px";
    button.style.marginBottom = "10px";
    button.style.backgroundColor = "red";
    button.style.borderColor = "red";
    tdOne.appendChild(button);

    var button = document.createElement("INPUT");
    button.type = "button";
    button.className = "btn btn-lg btn-primary addLink";
    button.value = "Add Link";
    button.id = "add_" + count;
    tdOne.appendChild(button);

    tr.appendChild(tdOne);

    tableBody.appendChild(tr);

    bigDiv.appendChild(table);

    bigDiv.appendChild(theButton);
}

function removeRowFunction(button) {

    var string = button.attr('id');

    var bigRow = getDesiredIndex(string, 0);

    var littleRow = getDesiredIndex(string, 1);

    var tableBody = document.getElementById("table_" + bigRow);

    var count = tableBody.getElementsByTagName('tr').length;

    if (littleRow == 0 && count == 2) {
        var here = $(this);

        BootstrapDialog.confirm({
            title: 'Confirmation',
            message: 'Deleting this link will delete the entire category, since it is the last one left. Are you sure?',
            type: BootstrapDialog.TYPE_DANGER, // <-- Default value is BootstrapDialog.TYPE_PRIMARY
            closable: true, // <-- Default value is false
            draggable: true, // <-- Default value is false
            btnCancelLabel: 'No', // <-- Default value is 'Cancel',
            btnOKLabel: 'Yes', // <-- Default value is 'OK',
            btnOKClass: 'btn-primary', // <-- If you didn't specify it, dialog type will be used,
            callback: function(result) {
                // result will be true if button was click, while it will be false if users close the dialog directly.
                if(result) {
                    var button = document.createElement('input');
                    button.id = "deleteCategory_" + bigRow;
                    var element = $(button);
                    deleteCategoryFunction(element);
                };
            }
        });
    } else {

        var rows = tableBody.getElementsByTagName('tr');

        for (var k = 0; k < rows.length; k++) {
            var ID = rows[k].id;
            if (ID) {
                var lastInt = getDesiredIndex(ID, 1);
                if (lastInt > littleRow) {
                    rows[k].id = "row_" + bigRow + "_" + (lastInt - 1).toString();
                };
            };
        };

        var boxes = tableBody.getElementsByTagName('td');

        for (var m = 0; m < boxes.length; m++) {
            var ID = boxes[m].id;
            if (ID) {
                var lastInt = getDesiredIndex(ID, 1);
                if (lastInt > littleRow) {
                    boxes[m].id = "box_" + bigRow + "_" + (lastInt - 1).toString();
                };
            };
        };

        var text = tableBody.getElementsByTagName('textarea');

        for (var n = 0; n < text.length; n++) {
            var ID = text[n].id;
            if (ID) {
                if (ID.indexOf("title") == 0) {
                    var lastInt = getDesiredIndex(ID, 1);
                    if (lastInt > littleRow) {
                        text[n].id = "title_" + bigRow + "_" + (lastInt - 1).toString();
                    };
                } else if (ID.indexOf("link") == 0) {
                    var lastInt = getDesiredIndex(ID, 1);
                    if (lastInt > littleRow) {
                        text[n].id = "link_" + bigRow + "_" + (lastInt - 1).toString();
                    };
                };
            };
        };

        var buttons = tableBody.getElementsByTagName('input');

        for (var o = 0; o < buttons.length; o++) {
            var ID = buttons[o].id;
            if (ID) {
                if (ID.indexOf("delete") > -1) {
                    var lastInt = getDesiredIndex(ID, 1);
                    if (lastInt > littleRow) {
                        buttons[o].id = "delete_" + bigRow + "_" + (lastInt - 1).toString();
                    };
                };
            };
        };

        var row = document.getElementById("row_" + bigRow + "_" + littleRow);

        row.parentNode.removeChild(row);

        if (littleRow == tableBody.rows.length - 1) {
            var box = document.getElementById("box_" + bigRow + "_" + (littleRow - 1));

            var button = document.createElement("INPUT");
            button.type = "button";
            button.className = "btn btn-lg btn-primary";
            button.value = "Add Link";
            button.id = "add_" + bigRow;
            button.onclick = (function() {

                return function(e) {

                    addRowFunction($(this));

                };
            })();
            box.appendChild(button);
        };
    };

}

function addRowFunction(button) {

    var string = button.attr('id');

    var bigRow = getDesiredIndex(string, 0);

    var tableBody = document.getElementById("table_" + bigRow);

    var button = document.getElementById("add_" + bigRow);

    button.parentNode.removeChild(button);

    var littleRow = tableBody.getElementsByTagName('tr').length - 1;

    var tr = document.createElement("TR");
    tr.id = "row_" + bigRow + "_" + littleRow;

    var tdOne = document.createElement("TD");

    var titleTextArea = document.createElement("TEXTAREA");
    titleTextArea.class = "form-control";
    titleTextArea.style.display = "block";
    titleTextArea.style.width = "100%";
    titleTextArea.style.overflowY = "scroll";
    titleTextArea.style.resize = "none";
    titleTextArea.id = "title_" + bigRow + "_" + littleRow;
    tdOne.appendChild(titleTextArea);
    tr.appendChild(tdOne);

    var tdOne = document.createElement("TD");

    var linkTextArea = document.createElement("TEXTAREA");
    linkTextArea.class = "form-control";
    linkTextArea.style.display = "block";
    linkTextArea.style.width = "100%";
    linkTextArea.style.overflowY = "scroll";
    linkTextArea.style.resize = "none";
    linkTextArea.id = "link_" + bigRow + "_" + littleRow;
    tdOne.appendChild(linkTextArea);
    tr.appendChild(tdOne);

    var tdOne = document.createElement("TD");
    tdOne.id = "box_" + bigRow + "_" + littleRow;

    var button = document.createElement("INPUT");
    button.type = "button";
    button.className = "btn btn-lg btn-primary deleteLink";
    button.value = "Delete";
    button.id = "delete_" + bigRow + "_" + littleRow;
    button.style.marginBottom = "10px";
    button.style.marginRight = "10px";
    button.style.backgroundColor = "red";
    button.style.borderColor = "red";
    tdOne.appendChild(button);

    var button = document.createElement("INPUT");
    button.type = "button";
    button.className = "btn btn-lg btn-primary addLink";
    button.value = "Add Link";
    button.id = "add_" + bigRow;
    tdOne.appendChild(button);

    tr.appendChild(tdOne);

    tableBody.appendChild(tr);
}

function reverseDictionary(dictionary) {
    var d = { };
    for (var i = 0; i < Object.keys(dictionary).length; i++) {
        var key = Object.keys(dictionary)[i];
        var value = dictionary[key];
        d[value] = key;
    }
    return d;
}

function prettyHtml(html) {
    var converter = new showdown.Converter();
    html = converter.makeHtml(html);
    html = html.replace(/<a href/g, '<a target="_blank" href');
    html = html.replace(/<hr/g, '<hr style="height: 5px; border-top-width: 5px; border-top-style: solid; border-top-color:#000000"');
    /*html = linkifyHtml(html, {
        target: '_blank'
    });*/
    return html;
}