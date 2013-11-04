function generateShiftPlan(totalWidth, cmPerTrip, loadTime, travelTime, unloadTime) {
    if (cmPerTrip <= 0 || loadTime < 0 || travelTime < 0 || unloadTime < 0) return [];
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
        $graph = $('#shift-plan'),
        tripWidth = 0,
        tripTime = 0;
    $graph.children('.trips, .actions').empty();
    shiftPlan.forEach(function(action, i) {
        var width = (action['time'] / totalTime * 100);
        $graph.find('.actions').append('<div title="' + action['name'] + ' - ' + minutesToString(action['time']) + '" class="shift-action shift-action-' + action['name'].toLowerCase() +
            '" style="width: ' + width + '%;" >&nbsp;</div>');
        tripWidth += width;
        tripTime += action['time'];
        if ((i + 1) % 4 == 0) {
            evenOdd = (((i + 1) / 4) % 2 == 0) ? 'even' : 'odd';
            $graph.find('.trips').append('<div title="Trip ' + ((i + 1) / 4) + ' - ' + minutesToString(tripTime) + '" class="shift-trip ' + evenOdd + '" style="width:' + tripWidth + '%;" >&nbsp;</div>');
            tripTime = 0;
            tripWidth = 0;
        }
    });
    $('#total-time').text(minutesToString(totalTime) + ' to shift');
    $('#total-trips').text((shiftPlan.length / 4) == 1 ? (shiftPlan.length / 4) + ' round trip' : (shiftPlan.length / 4) + ' round trips');
    $graph.find('.total-trip').remove();
    $('#shift-plan').append('<div class="total-trip" title="Total Shift - ' + minutesToString(totalTime) + '">&nbsp;</div>');
    $('.shift-trip, .shift-action, .total-trip').tooltip();
}
