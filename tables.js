<script type="text/javascript">
function sort(table, col) {
    var prevCol = -1;
    if (table.hasOwnProperty("s3g_prevCol")) {
        prevCol = table.s3g_prevCol;
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
    for(var i = 1; i < len; i++) {
        var row = rows[i];
        var item = {};
        item.oldkey = i; // to enforce stable sort
        //console.log(row.cells[col].textContent);
        item.newkey = row.cells[col].textContent;
        item.row = rows[i];
        items.push(item);
    }
    items.sort(function(a, b) {
        var lc = a.newkey.localeCompare(b.newkey);
        if (lc != 0) {
            return lc * order;
        }
        return (item.oldkey - item.newkey) * order;
    });
    for (var i = 0, len = items.length; i < len; i++) {
        table.appendChild(items[i].row);
    }
    items = null;
}
</script>
