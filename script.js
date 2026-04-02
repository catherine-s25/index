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

    // Display rec nicely
    summary.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;

  } catch (err) {
    processing.classList.add("hidden");
    summary.innerText = "Request failed: " + err;
  }
});
