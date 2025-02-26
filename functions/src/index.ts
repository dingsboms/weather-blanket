// import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/https";
const { getFirestore } = require("firebase-admin/firestore");

admin.initializeApp();

// TODO add CORS

exports.getPlaceDetails = onCall(async (request) => {
    const sessionToken: string = request.data.sessionToken || "";
    const placeId: string = request.data.placeId;

    const places_api_key = process.env.GOOGLE_PLACES_KEY;

    const places_detail_endpoint =
        `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&sessionToken=${sessionToken}&fields=geometry&key=${places_api_key}`;

    const response = await fetch(places_detail_endpoint);
    const result = await response.json();

    return result;
});

exports.getPlacesSuggestions = onCall(async (request) => {
    const input: string = request.data.input;
    const languageCode: string = request.data.languageCode || "";
    const sessionToken: string = request.data.sessionToken || "";

    const places_api_key = process.env.GOOGLE_PLACES_KEY;

    const places_autocomplete_endpoint =
        `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${input}&language=${languageCode}&sessionToken=${sessionToken}&key=${places_api_key}`;

    const response = await fetch(places_autocomplete_endpoint);
    const result = await response.json();

    return result;
});

exports.getGeoLocationFromAddress = onCall(async (request) => {
    const address = request.data.address;
    const geocode_api_key = process.env.GOOGLE_GEOCODING_KEY;
    const geocode_endpoint =
        `https://maps.googleapis.com/maps/api/geocode/json?address=${address}&key=${geocode_api_key}`;

    const response = await fetch(geocode_endpoint);
    const geocode_data = await response.json();

    const status = geocode_data["status"];
    const results = geocode_data["results"];

    if (status != "OK") {
        return { err: "API-call failed", status: status };
    }

    for (var i in results) {
        var result = results[i];
        let place_id = result["place_id"];
        let address_components = result["address_components"];
        let long_names = [];
        for (var i in address_components) {
            let component = address_components[i];
            let long_name = component["long_name"];
            long_names.push(long_name);
        }
        await getFirestore().collection("geoLocations").doc(place_id).set(
            { ...result, long_names },
            { merge: true },
        );
    }

    return geocode_data;
});

exports.getAddressFromGeoLocation = onCall(async (request) => {
    const lat = request.data.lat;
    const lon = request.data.lon;

    const geocode_api_key = process.env.GOOGLE_GEOCODING_KEY;

    const reverse_geocoding_endpoint =
        `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lon}&key=${geocode_api_key}`;

    const response = await fetch(reverse_geocoding_endpoint);
    const result = await response.json();

    return result;
});

exports.fetchOpenWeatherData = onCall(async (request) => {
    let date_utc = request.data.date;
    let lat = request.data.lat;
    let lon = request.data.lon;
    // const uid = request.auth.uid;

    let open_weather_api_key = process.env.OPEN_WEATHER_API_KEY;
    let open_weather_endpoint =
        `https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=${lat}&lon=${lon}&dt=${date_utc}&appid=${open_weather_api_key}&units=metric`;

    const response = await fetch(open_weather_endpoint);
    const weatherdata = await response.json();

    // await getFirestore()
    //     .collection("messages")
    //     .add(weatherdata);

    return weatherdata;
});

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
