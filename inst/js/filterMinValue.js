// Filter method that filters numeric columns by minimum value
function filterMinValue(rows, columnId, filterValue) {
  return rows.filter(function(row) {
    return row.values[columnId] >= filterValue
  })
}
