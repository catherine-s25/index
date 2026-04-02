document.getElementById("uploadForm").addEventListener("submit", async function(e) {
  e.preventDefault();

  const formData = new FormData(this);
  const processing = document.getElementById("processing");
  const resultsDiv = document.getElementById("results");
  const summary = document.getElementById("summary");

  processing.classList.remove("hidden");

  try {
    const response = await fetch("/run", {
      method: "POST",
      body: formData
    });

    const data = await response.json();

    processing.classList.add("hidden");
    resultsDiv.classList.remove("hidden");

    if (data.error) {
      summary.innerText = "Error: " + data.error;
      return;
    }

    // ----------------------------
    // Option B: Display as tables
    // ----------------------------
    let html = "";

    for (let cellType in data) {
      html += `<h4>${cellType}</h4>`; // Header for this cell type

      // Start table
      html += "<table border='1' style='border-collapse: collapse;'>";
      
      // Table header
      const firstRow = data[cellType][0];
      html += "<tr>";
      for (let col in firstRow) {
        html += `<th style="padding: 4px; text-align: left;">${col}</th>`;
      }
      html += "</tr>";

      // Table rows
      for (let row of data[cellType]) {
        html += "<tr>";
        for (let col in row) {
          html += `<td style="padding: 4px;">${row[col]}</td>`;
        }
        html += "</tr>";
      }

      html += "</table><br/>";
    }

    summary.innerHTML = html;

  } catch (err) {
    processing.classList.add("hidden");
    summary.innerText = "Request failed: " + err;
  }
});
