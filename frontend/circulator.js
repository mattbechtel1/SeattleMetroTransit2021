document.addEventListener("DOMContentLoaded", function() {
    document.getElementById('circulator-by-route').addEventListener('click', function() {
        clearAndReturnMain()
        loaderNotification("Getting bus routes...")

        fetch(`${baseUrl}/circulator/busroutes`)
        .then(response => response.json())
        .then(data => {
            if (data.body.Error) {
                displayError(data.body.Error)
            }
            clearAndReturnNotification()
            getRoutes(data.body.route, 'circulator')
        })
    })
})

function getStopNameByTag(tag, stopList) {
    return stopList.find(stop => stop.tag == tag).title
}

function displayCirculatorStops({title: title, stop: stops, direction: directions}) {
    const mainContainer = clearAndReturnMain()
    let div = document.createElement('div')
    div.innerText = "You have selected " + title + "."
    
    const dropdownForm = document.createElement('form')
    dropdownForm.id = 'select-direction-form'
    
    const outerDirectionDiv = document.createElement('div')
    outerDirectionDiv.classList.add('field', 'has-addons')
    dropdownForm.appendChild(outerDirectionDiv)
    
    const innerDirectionDiv1 = document.createElement('div')
    outerDirectionDiv.classList.add('control')
    
    const innerDirectionDiv2 = document.createElement('div')
    innerDirectionDiv2.classList.add('select')
    innerDirectionDiv1.appendChild(innerDirectionDiv2)
    
    const buildOption = (direction, selection) => {
        let option = document.createElement('option')
        option.innerText = direction.title + " TOWARD " + getStopNameByTag(direction.stop[direction.stop.length -1].tag, stops)
        option.value = selection
        return option
    }

    const options = directions.map(direction => buildOption(direction, direction.tag))
    
    const dropdownSelect = document.createElement('select')
    dropdownSelect.setAttribute('name', 'direction')
    dropdownSelect.classList.add('select', 'is-info')
    innerDirectionDiv2.appendChild(dropdownSelect)
    dropdownSelect.append(...options)

    const directionBtnDiv = document.createElement('div')
    directionBtnDiv.classList.add('control')
    
    const directionSubmitBtn = createSubmit('Submit')
    directionBtnDiv.appendChild(directionSubmitBtn)
    
    innerDirectionDiv2.append(dropdownSelect);
    outerDirectionDiv.append(innerDirectionDiv1, directionBtnDiv)
    dropdownForm.addEventListener('submit', (e) => listCirculatorRouteStops(e, stops, directions))
    mainContainer.append(div, dropdownForm)
}

function listCirculatorRouteStops(event, stops, directions) {
    event.preventDefault()

    let directionKey = event.target.direction.value;
    const ul = document.createElement('ul')
    const dirStops = directions.find(direction => direction.tag === directionKey).stop

    function convertTagToStop(tag) {
        return stops.find(stop => stop.tag === tag)
    }

    dirStops.forEach(stop => {
        let stopObj = convertTagToStop(stop.tag)
        const li = document.createElement('li')
        const link = document.createElement('a')
        link.innerText = "Stop " + stopObj.stopId + ": " + stopObj.title
        li.appendChild(link)
        li.addEventListener('click', function() {
            loaderNotification(`Finding the schedule for stop #${stopObj.stopId}`)
            
            fetch(`${baseUrl}/circulator/busstop/${stopObj.stopId}`)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    displayError(data.error)
                } else {
                    clearAndReturnNotification()
                    getCirculatorBuses(data.body.predictions, stopObj.stopId)
                }
            }) 
            .catch(displayError)
            })
        ul.appendChild(li)
    })

    const mainContainer = clearAndReturnMain()
    mainContainer.append(ul)
}

function getCirculatorBuses(predictions, stopNumber, heading, tableBody) {
    const mainContainer = clearAndReturnMain()

    if (!heading) {
        heading = buildHeader(stopNumber, null, "circulator")
        mainContainer.append(heading)
    }

    if (!tableBody) {
        tableBody = document.createElement('tbody')
    }

    let predictions_list
    if (Array.isArray(predictions)) {
        predictions.forEach(busRoute => getCirculatorBuses(busRoute, stopNumber, heading, tableBody))
        table = document.createElement('table')
        table.classList.add('table', 'is-hoverable')
        table.appendChild(tableBody)
        mainContainer.append(table)
        return
    } else {
        if (predictions.direction) {
            predictions_list = predictions.direction.prediction
            table = document.createElement('table')
            table.classList.add('table', 'is-hoverable')
            table.appendChild(tableBody)
            mainContainer.append(table)
        }
        else if (predictions.dirTitleBecauseNoPredictions) {
            displayError(`No current predictions for ${predictions.stopTitle}`)
            return
        }
    }

    predictions_list.forEach(bus => {
        let row = document.createElement('tr')

        let busNum = document.createElement('td');
        const busBox = document.createElement('div');
        busBox.classList.add('circulator-box')
        busBox.innerText = predictions.routeTitle;

        const busDesc = document.createElement('div')
        busDesc.classList.add('bus-description')
        busDesc.innerText = " " + predictions.direction.title;
        busNum.append(busBox, busDesc)

        let busMinutes = document.createElement('td');
        busMinutes.innerText = bus.minutes + ' minutes';
        let alarmSet = document.createElement('a');
        alarmSet.addEventListener('click', e => askAlarm(e, 'circulator'));
        alarmSet.dataset.stop = stopNumber;
        alarmSet.dataset.minutes = bus.minutes;
        alarmSet.dataset.tripId = bus.tripTag;
        alarmSet.classList.add('clickable-emoji')
        alarmSet.innerText = '⏰';
        row.append(busNum, busMinutes, alarmSet)
        tableBody.appendChild(row)
    })
}