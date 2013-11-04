function generateShiftPlan(totalWidth, cmPerTrip, loadTime, travelTime, unloadTime) {
    var shiftPlan = [],
        numTrips = totalWidth / cmPerTrip,
        fullTrips = Math.floor(numTrips),
        lastTripFullness = numTrips - fullTrips;

    for (var i = 0; i < fullTrips; i++) {
        shiftPlan.push(
            { name: 'Load', time: loadTime},
            { name: 'Travel', time: travelTime},
            { name: 'Unload', time: unloadTime},
            { name: 'Return', time: travelTime}
        );
    }

    shiftPlan.push(
        { name: 'Load', time: loadTime * lastTripFullness},
        { name: 'Travel', time: travelTime},
        { name: 'Unload', time: unloadTime * lastTripFullness},
        { name: 'Return', time: travelTime}
    );

    return shiftPlan;
}

function totalShiftPlanTime(shiftPlan) {
    return shiftPlan.reduce(function(time, action) { return time + action['time']; }, 0);
}

function minutesToString(minutes) {
    var output = '',
        hours = Math.floor(minutes / 60),
        minutes = Math.round(minutes - hours * 60);

    if (hours > 0) output += hours + ' hour';
    if (hours > 1) output += 's';
    output += ' ';
    if (minutes > 0) output += minutes + ' minute';
    if (minutes > 1) output += 's';
    return output;
}

function graphShiftPlan(shiftPlan) {
    var totalTime = totalShiftPlanTime(shiftPlan),
        $graph = $('#shift-plan');
    if ($graph.children().length > 0) $graph.empty();
    shiftPlan.forEach(function(action) {
        $graph.append('<div title="' + action['name'] + '" class="shift-action shift-action-' + action['name'].toLowerCase() +
            '" style="width: ' + (action['time'] / totalTime * 100) + '%;" >&nbsp;</div>');
    });
    $('#total-time').text(minutesToString(totalTime));
    $('#total-trips').text((shiftPlan.length / 4) > 1 ? (shiftPlan.length / 4) + ' round trips' : (shiftPlan.length / 4) + ' round trip');
}
