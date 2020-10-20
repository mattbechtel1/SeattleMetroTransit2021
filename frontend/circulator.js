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
                debugger
                if (data.error) {
                    displayError(data.error)
                } else {
                    clearAndReturnNotification()
                    // Start coding here for predictions body.predictions
                    // When none, body.predictions[#].dirTitleBecauseNoPredictions exists
                    // checkForBuses(data.stop, stopTime.StopID)
                }
            }) 
            .catch(displayError)
            })
        ul.appendChild(li)
    })

    const mainContainer = clearAndReturnMain()
    mainContainer.append(ul)
}