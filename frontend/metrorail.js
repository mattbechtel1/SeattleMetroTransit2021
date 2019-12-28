const lineListUrl = 'https://api.wmata.com/Rail.svc/json/jLines'
const stationListUrlPrefix = 'https://api.wmata.com/Rail.svc/json/jStations'
const stationPredictionsUrlPrefix = 'https://api.wmata.com/StationPrediction.svc/json/GetPrediction/'

const colors = {'OR': 'orange', 'BL': 'blue', 'RD': 'red', 'SV': 'silver', 'GR': 'green', 'YL': 'yellow'}


document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('search-by-station').addEventListener('click', function() {
        fetch(stationListUrlPrefix, configObj)
        .then(response => response.json())
        .then(data => listStations(data.Stations))
    });
    document.getElementById('search-by-line').addEventListener('click', function() {
        fetch(lineListUrl, configObj)
        .then(response => response.json())
        .then(data => displayLineSearch(data.Lines))
    });
})

function listStations(stations) {
    if (stations.length > 40) {
        stations = reorderStations(stations, 'Name')
    } else {
        stations = reorderStations(stations, 'Lon')
    }

    stations = reorderStations(stations)

    const mainContainer = clearAndReturnMain()

    const form = buildDropDownForm(stations, function(station) {
        const option = document.createElement('option')
        option.value = station.Code
        option.innerText = station.Name

        return option
    })

    form.addEventListener('submit', function(e) {
        e.preventDefault()

        fetch(stationPredictionsUrlPrefix + event.target.opt.value, configObj)
        .then(response => response.json())
        .then(data => displayTrains(data.Trains))
    })

    mainContainer.appendChild(form)
}

function reorderStations(stationsList, key) {
    return stationsList.sort(function(a, b) {
        return (a[key] < b[key]) ? 1 : -1
    })
}

function displayLineSearch(lines) {
    const mainContainer = clearAndReturnMain()

    const metroLineForm = buildDropDownForm(lines, function(line) {
        const option = document.createElement('option')
        option.value = line.LineCode;
        option.innerText = line.DisplayName;

        return option
    })

    metroLineForm.addEventListener('submit', function(e) {lineSearch(e)})

    mainContainer.appendChild(metroLineForm);
}

function lineSearch(event) {
    event.preventDefault()

    fetch(stationListUrlPrefix + '?Linecode=' + event.target.opt.value, configObj)
    .then(response => response.json())
    .then(data => listStations(data.Stations))
}

function buildDropDownForm(optionsList, forEachCallback) {
    const form = document.createElement('form');
    form.id = 'metroline-filter-form'

    const outerDiv = document.createElement('div')
    outerDiv.classList.add('field', 'has-addons')
    form.appendChild(outerDiv)

    const innerDiv1 = document.createElement('div')
    innerDiv1.classList.add('control')

    const innerDiv2 = document.createElement('div')
    innerDiv2.classList.add('select')
    innerDiv1.appendChild(innerDiv2)

    const select = document.createElement('select')
    select.setAttribute('name', 'opt')
    const defaultOpt = document.createElement('option')

    defaultOpt.innerText = "Select an Option"
    select.appendChild(defaultOpt)

    optionsList.forEach(function(option) {
        select.appendChild(forEachCallback(option))
    })

    innerDiv2.appendChild(select)

    const btnDiv = document.createElement('div');
    btnDiv.classList.add('control')

    let btn = document.createElement('button');
    btn.innerText = 'Go To Line'
    btn.type = 'submit'
    btn.classList.add('button', 'is-primary')
    btnDiv.appendChild(btn)

    outerDiv.append(innerDiv1, btnDiv)

    return form
}

function displayTrains(trains) {
    const mainContainer = clearAndReturnMain()
    
    if (trains.length < 1) {
        mainContainer.innerHTML = "No buses found."
    } else {
        
        const table = document.createElement('table')
        table.classList.add('table')
        const tableBody = document.createElement('tbody')
        table.appendChild(tableBody)
        
        trains.forEach(function(prediction) {
            let row = document.createElement('tr');
            
            let trainColor = document.createElement('td');
            const trainBox = document.createElement('div');
            trainBox.classList.add('busbox')
            trainBox.style.color = colors[prediction.Line]
            trainBox.innerText = prediction.Line;
            
            const trainDesc = document.createElement('div')
            // trainDesc.classList.add('bus-description')
            trainDesc.innerText = " toward " + prediction.DestinationName;
            trainColor.append(trainBox, trainDesc)
            
            let trainMinutes = document.createElement('td');
            if (!!parseInt(prediction.Min)) {
                trainMinutes.innerText = prediction.Min + ' minutes';
            } else {
                trainMinutes.innerText = prediction.Min
            }

            // let alarmSet = document.createElement('a');
            // alarmSet.addEventListener('click', askAlarm);
            // alarmSet.dataset.stop = stopId;
            // alarmSet.dataset.minutes = prediction.Minutes;
            // alarmSet.dataset.tripId = prediction.TripID;
            // alarmSet.innerText = '⏰';
            
            row.append(trainColor, trainMinutes
                // , alarmSet
                )
            tableBody.appendChild(row)
        })
        mainContainer.appendChild(table)
    }

}