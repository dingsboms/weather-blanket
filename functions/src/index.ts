// import { onSchedule } from "firebase-functions/v2/scheduler";
// import * as admin from "firebase-admin";
// import { onCall } from "firebase-functions/https";
// const { getFirestore } = require("firebase-admin/firestore");

// admin.initializeApp();

// exports.testCall = onCall(async (request) => {
//   let date_utc = request.data.date;
//   // const uid = request.auth.uid;

//   let open_weather_api_key = process.env.OPEN_WEATHER_API_KEY;
//   let open_weather_endpoint =
//     `https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=59.9139&lon=10.7522&dt=${date_utc}&appid=${open_weather_api_key}&units=metric`;

//   const response = await fetch(open_weather_endpoint);
//   const weatherdata = await response.json();

//   await getFirestore()
//     .collection("messages")
//     .add(weatherdata);

//   return weatherdata;
// });

// exports.dailyApiFetch = onSchedule("every day 12:00", async (event) => {
//   try {
//     // Fetch data from your API
//     const oslo_met_weather_api_endpoint =
//       "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.9139&lon=10.7522";
//     const response = await fetch(oslo_met_weather_api_endpoint);
//     const data = await response.json();

//     // Store the data in Firestore
//     const db = admin.firestore();
//     await db.collection("days").add({
//       data: data,
//       timestamp: admin.firestore.FieldValue.serverTimestamp(),
//       is_knitted: false,
//     });

//     console.log("Successfully fetched and stored API data");
//     return;
//   } catch (error) {
//     console.error("Error fetching API data:", error);
//     throw error;
//   }
// });
