const busPredictionPrefix = 'https://api.wmata.com/NextBusService.svc/json/jPredictions/?StopID='
const busRouteListUrl = 'https://api.wmata.com/Bus.svc/json/jRoutes'
const routeScheduleUrlPrefix = 'https://api.wmata.com/Bus.svc/json/jRouteSchedule'
const alarmSound = new Audio('./assets/charge.wav');
const confirmSound = new Audio('./assets/263133__pan14__tone-beep.wav');
const lostSound = new Audio('./assets/159408__noirenex__life-lost-game-over.wav');

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('search-by-stop').addEventListener('click', () => popUpSearch(stopSearch));
    document.getElementById('search-by-route').addEventListener('click', function() {
        popUpSearch(routeSearch);
        fetch(busRouteListUrl, configObj)
        .then(response => response.json())
        .then(data => getRoutes(data.Routes))
        });
    document.getElementById('favorites').addEventListener('click', getFavorites)
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
        alert('Invalid stop number');
        return;
    } else {
        stopId = busStop;
    }

    fetch(busPredictionPrefix + stopId, configObj)
    .then(response => response.json())
    .then(data => checkForBuses(data, stopId))
    .catch(error => alert(error.message))
}

function routeSearch(event) {
    event.preventDefault();

    let form = event.currentTarget
    let query = form.queryData.value.toString().toUpperCase();

    if (query.length > 4 ) {
        alert('Invalid stop number');
        return;
    }

    const today = new Date()
    let year = today.getFullYear()
    let month;
        if (((today.getMonth() + 1).toString()).length < 1) {
            month = '0' + (today.getMonth() + 1)
        } else {
            month = today.getMonth() + 1
        }
    let day; 
        if (((today.getDate()).toString()).length < 1) {
            day = '0' + today.getDate()
        } else {
            day = today.getDate();
        }
    
    let queryDate = year + '-' + month + '-' + day;

    let fullUrl = routeScheduleUrlPrefix + '?RouteID=' + query + '&Date=' + queryDate + 'IncludingVariations=true'
    
    fetch(fullUrl, configObj)
    .then(response => response.json())
    .then(data => {
        if (!!data.Message) {
            alert(data.Message)
            return;
        } else {
        displaySchedule(data) }
    })
    .catch(error => alert(error.message))
}

function buildHeader(stopId) {
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
    favoriteHeart.innerText = '💗'
    favoriteHeart.dataset.stop = stopId
    favoriteHeart.dataset.stopType = 'bus'
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

    secondBtn = document.createElement('button');
    secondBtn.innerText = 'Go To Route'
    secondBtn.type = 'submit'
    secondBtn.classList.add('button', 'is-primary')
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
    
    let directionSubmitBtn = document.createElement('button')
    directionSubmitBtn.classList.add('button', 'is-primary')
    directionSubmitBtn.innerText = 'Submit'
    directionSubmitBtn.type = 'submit'
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
            fetch(busPredictionPrefix + stopTime.StopID, configObj)
            .then(response => response.json())
            .then(data => checkForBuses(data, stopTime.StopID)) 
            })
        ul.appendChild(li)
    })

    const mainContainer = clearAndReturnMain()
    mainContainer.append(ul)
}

function checkForBuses(data, stopId) {
    if (!!data.Message) {
        alert(data.Message)
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
    let internalSubmit = document.createElement('button');
    internalSubmit.classList.add('button', 'is-primary')
    internalSubmit.type = 'submit';
    internalSubmit.innerText = "Set Alarm"
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
    const notificationBlock = document.getElementById('notification-block');
    notificationBlock.classList.add('notification', 'is-success');
    let closeBtn = document.createElement('button')
    closeBtn.classList.add('delete')
    closeMarker = document.createElement('i')
    closeMarker.classList.add('fas', 'fa-times')
    closeBtn.appendChild(closeMarker)
    notificationBlock.appendChild(closeBtn);
    confirmSound.play()
    notificationBlock.innerText = `An alarm has been set for bus #${tripId} at stop #${stopId} with ${alarmSettingMins} minutes' warning.`
    
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
            alert("We're sorry. Your selected bus is no longer providing prediction data.")
            notificationBlock.innerHTML = ""
        }
    };
    
    let alarm = setInterval(function () {
        fetch(busPredictionPrefix + stopId, configObj)
        .then(response => response.json())
        .then(data => { checkAlarm(data.Predictions)
            getBuses(data, stopId)
        })
    }, 30000)
}