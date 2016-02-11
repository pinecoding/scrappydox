<script type="text/javascript">
function sort(table, col) {
    if (table.hasOwnProperty("s3g_prevCol")) {
        var prevCol = table.s3g_prevCol;
    }
    else {
        var prevCol = -1;
    }
    table.s3g_prevCol = col;
    var order = 1;
    if (col == prevCol) {
        if (table.hasOwnProperty("s3g_prevOrd")) {
            order = table.s3g_prevOrd * (-1);
        }
    }
    table.s3g_prevOrd = order;
    var items = [];
    var rows = table.rows;
    var len = rows.length;
    var dataLength = rows.length - 1;
    var numeric = true;
    for (var i = 1; i < len; i++) {
        var row = rows[i];
        var item = {};
        item.oldkey = i; // to enforce stable sort
        //console.log(row.cells[col].textContent);
        var textval = row.cells[col].textContent;
        if (numeric && isNaN(textval)) {
            numeric = false;
        }
        item.newkey = textval;
        item.row = rows[i];
        items.push(item);
    }
    if (numeric) {
        for (var i = 0, len = items.length; i < len; i++) {
            var item = items[i];
            item.newkey = Number(item.newkey);
        } 
    }
    items.sort(function(a, b) {
        if (numeric) {
            var c = a.newkey - b.newkey;
        }
        else {
            var c = a.newkey.localeCompare(b.newkey);
        }
        if (c != 0) {
            return c * order;
        }
        return a.oldkey - b.oldkey
    });
    for (var i = 0, len = items.length; i < len; i++) {
        table.appendChild(items[i].row);
    }
    items = null;
}
</script>
