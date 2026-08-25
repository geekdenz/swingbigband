(() => {
  const button = document.querySelector("[data-directions-from-location]");
  const status = document.querySelector("[data-location-status]");

  if (!button || !status) {
    return;
  }

  const destination = button.dataset.destination;
  const originalLabel = button.textContent;

  button.addEventListener("click", () => {
    if (!navigator.geolocation) {
      status.textContent = "Location is not available in this browser. Use the Google Maps link below instead.";
      return;
    }

    button.disabled = true;
    button.textContent = "Finding your location…";
    status.textContent = "Your location is requested only to create this directions link.";

    navigator.geolocation.getCurrentPosition(
      ({ coords }) => {
        const directions = new URL("https://www.google.com/maps/dir/");
        directions.searchParams.set("api", "1");
        directions.searchParams.set("origin", `${coords.latitude},${coords.longitude}`);
        directions.searchParams.set("destination", destination);
        window.location.assign(directions.toString());
      },
      () => {
        button.disabled = false;
        button.textContent = originalLabel;
        status.textContent = "We could not access your location. Use the Google Maps link below and enter your starting point.";
      },
      {
        enableHighAccuracy: false,
        timeout: 10000,
        maximumAge: 300000,
      },
    );
  });
})();
