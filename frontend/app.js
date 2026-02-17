document.getElementById("runPipeline").addEventListener("click", function () {
  const steps = document.querySelectorAll(".step");
  steps.forEach(step => step.classList.remove("active"));

  steps.forEach((step, index) => {
    setTimeout(() => {
      step.classList.add("active");
    }, index * 1000);
  });
});
