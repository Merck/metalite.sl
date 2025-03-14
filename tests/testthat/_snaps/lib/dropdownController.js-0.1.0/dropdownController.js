// Filter method that filters numeric columns by minimum value
function dropdownController(selectedPlot) {
  const uniqueIds = [];
  const elements = document.querySelectorAll('[id*="histogram_type_"]');

  for (const element of elements) {
    const id = element.id;
    if (!uniqueIds.includes(id)) {
      uniqueIds.push(id);
    }
  }
  console.log(uniqueIds);
  uniqueIds.forEach(function(plot) {
    document.getElementById(plot).style.display = 'none';
  });
  if (selectedPlot) {
    document.getElementById(selectedPlot).style.display = 'block';
  }
}
