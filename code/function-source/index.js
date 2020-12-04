/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */

const maps = require('@google/maps').createClient({
    key: "CLIENT_KEY",
    Promise: Promise
});

const getDistance = async (body) => {
    var results = await maps.placesNearby({
        keyword: 'PUC Minas',
        type: 'university',
        radius: body.radius,
        location: [body.lat, body.lng],
        name: "PUC Minas",
    })
        .asPromise();
    
    var unitys = results.json.results.map(e => ({
        name: e.name,
        location: e.geometry.location,
        distance: distance(e.geometry.location.lat, e.geometry.location.lng, body.lat, body.lng)
    }))

    var nearbyUnits = unitys.filter(p => p.distance < body.radius);
    nearbyUnits.sort(function(a, b){return a.distance - b.distance});

    if (nearbyUnits.length > 0) {
        return {
            message: "Bem vindo à PUC Minas unidade " + nearbyUnits[0].name
        };
    } else {
        return {
            message: "",
        };
    }
}

function distance(lat1, lon1, lat2, lon2) {
    if ((lat1 == lat2) && (lon1 == lon2)) {
        return 0;
    }
    else {
        var radlat1 = Math.PI * lat1 / 180;
        var radlat2 = Math.PI * lat2 / 180;
        var theta = lon1 - lon2;
        var radtheta = Math.PI * theta / 180;
        var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
        if (dist > 1) {
            dist = 1;
        }
        dist = Math.acos(dist);
        dist = dist * 180 / Math.PI;
        dist = dist * 60 * 1.1515;
        dist = dist * 1.609344
        return (dist * 1000);
    }
}



exports.http = async (req, res) => {
console.log(req);
    const body = req.body;
    const result = await getDistance(body);
    res.status(200).send(result);
}