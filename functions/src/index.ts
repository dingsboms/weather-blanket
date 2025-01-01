import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

export const dailyApiFetch = onSchedule("every day 12:00", async (event) => {
  try {
    // Fetch data from your API
    const oslo_met_weather_api_endpoint =
      "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.9139&lon=10.7522";
    const response = await fetch(oslo_met_weather_api_endpoint);
    const data = await response.json();

    // Store the data in Firestore
    const db = admin.firestore();
    await db.collection("days").add({
      data: data,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      is_knitted: false,
    });

    console.log("Successfully fetched and stored API data");
    // Don't return null, just return
    return;
  } catch (error) {
    console.error("Error fetching API data:", error);
    throw error;
  }
});
