const colors = {'OR': 'orange', 'BL': 'blue', 'RD': 'red', 'SV': 'silver', 'GR': 'green', 'YL': 'yellow'}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('search-by-station').addEventListener('click', function() {
        
        loaderNotification("Finding stations...")

        fetch(`${baseUrl}/metro/stations`)
        .then(response => response.json())
        .then(data => {
            listStations(data.Stations)
            clearAndReturnNotification()
        })
        .catch(displayError)
    });
    document.getElementById('search-by-line').addEventListener('click', function() {
        
        loaderNotification('Finding metrolines...')

        fetch(`${baseUrl}/metro/lines`)
        .then(response => response.json())
        .then(data => {
            clearAndReturnNotification()
            displayLineSearch(data.Lines)
        })
        .catch(displayError)
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
        option.value = [station.Code, station.Name]
        option.innerText = station.Name

        return option
    }, 'Go to Station')

    form.addEventListener('submit', function(e) {
        e.preventDefault()

        loaderNotification(`Finding the train schedule for ${e.target.opt.value.split(',')[1]}`)
        
        fetch(`${baseUrl}/metro/station/${e.target.opt.value.split(',')[0]}`)
        .then(response => response.json())
        .then(data => {
            displayTrains(data.Trains, e.target.opt.value.split(',')[1], e.target.opt.value.split(',')[0])
            clearAndReturnNotification()
        })
        .catch(displayError)
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
    }, 'Go to Line')

    metroLineForm.addEventListener('submit', function(e) {lineSearch(e)})

    mainContainer.appendChild(metroLineForm);
}

function lineSearch(event) {
    event.preventDefault()

    loaderNotification(`Finding stations on the ${colors[event.target.opt.value]} line...`)

    fetch(`${baseUrl}/metro/stations?Linecode=${event.target.opt.value}`)
    .then(response => response.json())
    .then(data => {
        loaderNotification(...data.alerts)
        listStations(data.stations.Stations)
    })
    .catch(displayError)
}

function buildDropDownForm(optionsList, forEachCallback, saveText) {
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

    let btn = createSubmit(saveText)
    btnDiv.appendChild(btn)

    outerDiv.append(innerDiv1, btnDiv)

    return form
}

function displayTrains(trains, stationName, stationCode) {
    const mainContainer = clearAndReturnMain()
    
    if (trains.length < 1) {
        mainContainer.innerHTML = "No trains found."
    } else {
        
        const heading = buildHeader(stationName, stationCode)

        const table = document.createElement('table')
        table.classList.add('table', 'is-hoverable')
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
            // alarmset.classList.add('clickable-emoji')
            // alarmSet.innerText = '⏰';
            
            row.append(trainColor, trainMinutes
                // , alarmSet
                )
            tableBody.appendChild(row)
        })
        mainContainer.append(heading, table)
    }

}