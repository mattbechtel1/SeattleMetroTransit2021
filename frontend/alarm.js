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
                clearAndReturnNotification()
            }
        }

        if (!myBus) {
            lostSound.play()
            errorNotification("We're sorry. Your selected bus is no longer providing prediction data.")
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