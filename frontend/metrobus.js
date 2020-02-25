const alarmSound = new Audio('./assets/charge.wav');
const confirmSound = new Audio('./assets/263133__pan14__tone-beep.wav');
const lostSound = new Audio('./assets/259172__xtrgamr__uhoh.wav');

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('search-by-stop').addEventListener('click', () => popUpSearch(stopSearch));
    document.getElementById('search-by-route').addEventListener('click', function() {
        popUpSearch(routeSearch);
        
        loaderNotification("Getting bus routes...")

        fetch(`${baseUrl}/metro/busroutes`)
        .then(response => response.json())
        .then(data => {
            getRoutes(data.Routes)
            clearAndReturnNotification()
        })
        .catch(displayError)
        });
    const favLink = document.getElementById('favorites')
    favLink.style.display = 'none'
    favLink.addEventListener('click', () => displayFavorites(userHeldInState.favorites))
})

function popUpSearch(searchFunction) {
    const mainContainer = clearAndReturnMain()

    const form = document.createElement('form');
    form.id = 'search-form'

    const outerDiv = document.createElement('div');
    outerDiv.classList.add('field', 'has-addons')
    form.appendChild(outerDiv)

    const innerDiv1 = document.createElement('div');
    innerDiv1.classList.add('control')

    const input = document.createElement('input');
    input.classList.add('input');
    input.setAttribute('name', 'queryData');
    input.setAttribute('maxlength', '7')
    input.setAttribute('placeholder', "Enter 7-digit stop # or route")
    innerDiv1.appendChild(input)

    const innerDiv2 = document.createElement('div')
    innerDiv2.classList.add('control')

    const submitBtn = createSubmit('Search')
    innerDiv2.appendChild(submitBtn)

    outerDiv.append(innerDiv1, innerDiv2)
    form.addEventListener('submit', (e) => searchFunction(e))
    mainContainer.appendChild(form)
}

function stopSearch(event) {
    event.preventDefault()
    
    let form = document.getElementById('search-form')
    const busStop = form.queryData.value.toString();
    let stopId;

    if (busStop.length !== 7 ) {
        errorNotification('Invalid stop number')
        return
    } else {
        stopId = busStop;
    }
    
    loaderNotification("Getting bus schedule for your stop...")

    fetch(`${baseUrl}/metro/busstop/${stopId}`)
    .then(response => response.json())
    .then(data => {
        if (data.Message) {
            errorNotification(data.Message)
        } else {
            checkForBuses(data, stopId)
            clearAndReturnNotification()
        }
    })
    .catch(displayError)
}

function routeSearch(event) {
    event.preventDefault();

    const form = event.currentTarget
    const query = form.queryData.value.toString().toUpperCase();
    
    if (query.length > 4 ) {
        errorNotification('Invalid route');
        return;
    }

    const fullUrl = `${baseUrl}/metro/busstops/?RouteID=${query}&IncludingVariations=true`
    
    loaderNotification('Finding bus stops associated with that route...')

    fetch(fullUrl)
    .then(response => response.json())
    .then(data => {
        if (data.Message) {
            errorNotification(data.Message)
            return;
        } else {
            clearAndReturnNotification()
            displaySchedule(data) }
    })
    .catch(displayError)
}

function buildHeader(stopId, searchCode) {
    const favoriteDiv = document.createElement('div')
    let describeText = function(stopId) {
        if (!isNaN(parseInt(stopId))) {
            return 'stop #' + stopId + '.'
        } else {
            return stopId + ' station.'
        }
    }(stopId)
    favoriteDiv.innerText = "You've selected " + describeText
    const favoriteHeart = document.createElement('a')
    favoriteHeart.classList.add('clickable-emoji')
    favoriteHeart.innerText = '💗'
    favoriteHeart.dataset.stop = searchCode || stopId
    favoriteHeart.dataset.description = stopId
    favoriteHeart.dataset.stopType = searchCode ? 'train' : 'bus'
    favoriteHeart.addEventListener('click', addFavorite)
    favoriteDiv.appendChild(favoriteHeart)

    return favoriteDiv
}

function getBuses(data, stopId) {
    const mainContainer = document.getElementById('main-container')
    if (data.Predictions.length < 1) {
        mainContainer.innerHTML = "No buses found."
    } else {
        mainContainer.innerHTML = ""

        const heading = buildHeader(stopId)
        
        const table = document.createElement('table')
        table.classList.add('table', 'is-hoverable')
        const tableBody = document.createElement('tbody')
        table.appendChild(tableBody)
        
        data.Predictions.forEach(function(prediction) {
            let row = document.createElement('tr');
            
            let busNum = document.createElement('td');
            const busBox = document.createElement('div');
            busBox.classList.add('busbox')
            busBox.innerText = prediction.RouteID;
            
            const busDesc = document.createElement('div')
            busDesc.classList.add('bus-description')
            busDesc.innerText = " " + prediction.DirectionText;
            busNum.append(busBox, busDesc)
            
            let busMinutes = document.createElement('td');
            busMinutes.innerText = prediction.Minutes + ' minutes';
            let alarmSet = document.createElement('a');
            alarmSet.addEventListener('click', askAlarm);
            alarmSet.dataset.stop = stopId;
            alarmSet.dataset.minutes = prediction.Minutes;
            alarmSet.dataset.tripId = prediction.TripID;
            alarmSet.classList.add('clickable-emoji')
            alarmSet.innerText = '⏰';
            
            row.append(busNum, busMinutes, alarmSet)
            tableBody.appendChild(row)
        })
        mainContainer.append(heading, table)
    }
}

function getRoutes(routeList) {
    const secondForm = document.createElement('form')
    secondForm.id = 'route-list-form'
    
    const routesListOuterDiv = document.createElement('div')
    routesListOuterDiv.classList.add('field', 'has-addons')
    secondForm.appendChild(routesListOuterDiv)

    const routesListInnerDiv1 = document.createElement('div')
    routesListInnerDiv1.classList.add('control')

    const routesListInnerDiv2 = document.createElement('div')
    routesListInnerDiv2.classList.add('select')
    routesListInnerDiv1.appendChild(routesListInnerDiv2)

    const select = document.createElement('select')
    select.setAttribute('name', 'queryData')
    const defaultOpt = document.createElement('option')

    defaultOpt.innerText = "Or select a route"
    select.appendChild(defaultOpt)

    routeList = filterRoutes(routeList)

    routeList.forEach(function(route) {
        const option = document.createElement('option')
        const routeNumber = route.RouteID;
        option.value = routeNumber;
        option.innerText = routeNumber + " " + route.LineDescription

        select.appendChild(option)
    })

    routesListInnerDiv2.appendChild(select)

    const btnDiv = document.createElement('div');
    btnDiv.classList.add('control')

    const secondBtn = createSubmit('Go To Route')
    btnDiv.appendChild(secondBtn)

    routesListOuterDiv.append(routesListInnerDiv1, btnDiv)

    secondForm.addEventListener('submit', function(e) {routeSearch(e)})

    const mainContainer = document.getElementById('main-container')
    mainContainer.appendChild(secondForm);
}

function displaySchedule(schedule) {
    const mainContainer = clearAndReturnMain()

    let div = document.createElement('div')
    div.innerText = "You have selected " + schedule.Name +"."

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

    const dropdownSelect = document.createElement('select')
    dropdownSelect.setAttribute('name', 'directionNum')
    dropdownSelect.classList.add('select', 'is-info')
    innerDirectionDiv2.appendChild(dropdownSelect)
    
    let opt0 = document.createElement('option');
    opt0.innerText = schedule.Direction0[0].TripDirectionText + " TOWARD " + schedule.Direction0[0].TripHeadsign
    opt0.value = 0
    let opt1 = document.createElement('option');
    opt1.innerText = schedule.Direction1[0].TripDirectionText + " TOWARD    " + schedule.Direction1[0].TripHeadsign
    opt1.value = 1
    
    dropdownSelect.append(opt0, opt1)

    const directionBtnDiv = document.createElement('div')
    directionBtnDiv.classList.add('control')
    
    const directionSubmitBtn = createSubmit('Submit')
    directionBtnDiv.appendChild(directionSubmitBtn)

    innerDirectionDiv2.append(dropdownSelect);
    outerDirectionDiv.append(innerDirectionDiv1, directionBtnDiv)

    dropdownForm.addEventListener('submit', (e) => listRouteStops(e, schedule))
    mainContainer.append(div, dropdownForm)
}

function filterRoutes(routeList) {
    return routeList.filter(function(route) {
        return route.RouteID.split('v').length < 2
    })
}

function listRouteStops(event, schedule) {
    event.preventDefault();

    let directionNumKey = 'Direction' + event.target.directionNum.value;
    const ul = document.createElement('ul')
    
    schedule[directionNumKey][0]["StopTimes"].forEach(stopTime => {
        const li = document.createElement('li')
        const link = document.createElement('a')
        link.innerText = "Stop Id: " + stopTime.StopID + " at " + stopTime.StopName
        li.appendChild(link)
        li.addEventListener('click', function() {

            loaderNotification(`Finding the schedule for stop #${stopTime.stopID}`)

            fetch(`${baseUrl}/metro/busstop/${stopTime.StopID}`)
            .then(response => response.json())
            .then(data => {
                clearAndReturnNotification()
                checkForBuses(data, stopTime.StopID)
            }) 
            .catch(displayError)
            })
        ul.appendChild(li)
    })

    const mainContainer = clearAndReturnMain()
    mainContainer.append(ul)
}

function checkForBuses(data, stopId) {
    if (!!data.Message) {
        errorNotification(data.Message)
    } else {
        getBuses(data, stopId)
    }
}

function askAlarm(event) {
    let tripContainer = event.target.parentNode;
    let newTr = document.createElement('tr')
    let newTd = document.createElement('td')
    newTd.setAttribute('colspan', '3')
    newTr.appendChild(newTd)
    let tripId = event.target.dataset.tripId;
    let stopId = event.target.dataset.stop;

    let internalForm = document.createElement('form');

    let internalInputLabel = document.createElement('label')
    internalInputLabel.classList.add('label')
    internalInputLabel.innerText = "Set reminder for number of minutes before departure:"
    let internalInput = document.createElement('input');
    internalInput.classList.add('input', 'is-primary')
    internalInput.setAttribute('type', 'number');
    internalInput.setAttribute('name', 'alarm');
    internalInput.setAttribute('min', '1');
    internalInput.setAttribute('max', event.target.dataset.minutes)
    let internalSubmit = createSubmit('Set Alarm')
    internalForm.addEventListener('submit', function(e) {setAlarm(e, stopId, tripId)})
    let internalClose = document.createElement('button');
    internalClose.classList.add('button', 'is-primary')
    internalClose.innerText = "Close"
    internalClose.addEventListener('click', closeAlarmDrawer)

    internalForm.append(internalInputLabel, internalInput, internalSubmit, internalClose)
    newTd.appendChild(internalForm)
    tripContainer.parentNode.appendChild(newTr)
    tripContainer.after(newTr)
}

function closeAlarmDrawer(event) {
    event.target.parentNode.remove()
}

function setAlarm(event, stopId, tripId) {
    event.preventDefault();
    const alarmSettingMins = event.target.alarm.value;
    
    //notification
    confirmNotification(`An alarm has been set for bus #${tripId} at stop #${stopId} with ${alarmSettingMins} minutes' warning.`)
    
    let checkAlarm = function(busPredictions) {
        let myBus = busPredictions.find(bus => bus.TripID === tripId)
        
        if (!!myBus) {
            if (myBus.Minutes <= alarmSettingMins) {
                alarmSound.play();
                clearInterval(alarm)
                notificationBlock.innerHTML = ""
                document.getElementById('main-container').innerHTML = ""
            }
        }

        if (!myBus) {
            lostSound.play()
            errorNotification("We're sorry. Your selected bus is no longer providing prediction data.")
            notificationBlock.innerHTML = ""
        }
    };
    
    let alarm = setInterval(function () {

        fetch(`${baseUrl}/metro/busstop/${stopId}`)
        .then(response => response.json())
        .then(data => { checkAlarm(data.Predictions)
            getBuses(data, stopId)
        })
        .catch(displayError)
    }, 30000)
}

function buildCloseBtn() {
    let closeBtn = document.createElement('button')
    closeBtn.classList.add('delete')
    closeMarker = document.createElement('i')
    closeMarker.classList.add('fas', 'fa-times')
    closeBtn.addEventListener('click', clearAndReturnNotification)
    closeBtn.appendChild(closeMarker)
    return closeBtn
}

function confirmNotification(message) {
    const notificationBlock = clearAndReturnNotification()
    confirmSound.play()
    notificationBlock.classList.add('notification', 'is-success');
    notificationBlock.innerText = message
    notificationBlock.appendChild(buildCloseBtn())
}

function errorNotification(message) {
    const notificationBlock = clearAndReturnNotification()
    notificationBlock.classList.add('notification', 'is-danger');
    notificationBlock.innerText = message
    notificationBlock.appendChild(buildCloseBtn())
    lostSound.play()
}

function displayError(error) {
    errorNotification(error.message)
}

function loaderNotification(message) {
    const notificationBlock = clearAndReturnNotification()
    notificationBlock.classList.add('notification', 'is-warning')
    notificationBlock.innerText = message
    notificationBlock.appendChild(buildCloseBtn())
}

function clearAndReturnNotification() {
    const notificationBlock = document.getElementById('notification-block');
    notificationBlock.classList.remove('notification', 'is-danger', 'is-success', 'is-warning')
    notificationBlock.innerHTML = ''
    return notificationBlock
}