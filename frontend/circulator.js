document.addEventListener("DOMContentLoaded", function() {
    document.getElementById('circulator-by-route').addEventListener('click', function() {
        fetch(`${baseUrl}/circulator/busroutes`)
        .then(response => response.json())
        .then(data => {
            getRoutes(data.body.route, 'circulator')
        })
    })
})

function getStopNameByTag(tag, stopList) {
    return stopList.find(stop => stop.tag == tag).title
}

function displayCirculatorStops({title: title, stop: stops, direction: directons}) {
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

    const options = directons.map(direction => buildOption(direction, direction.tag))
    
    const dropdownSelect = document.createElement('select')
    dropdownSelect.setAttribute('name', 'directionNum')
    dropdownSelect.classList.add('select', 'is-info')
    innerDirectionDiv2.appendChild(dropdownSelect)
    dropdownSelect.append(...options)

    const directionBtnDiv = document.createElement('div')
    directionBtnDiv.classList.add('control')
    
    const directionSubmitBtn = createSubmit('Submit')
    directionBtnDiv.appendChild(directionSubmitBtn)
    
    innerDirectionDiv2.append(dropdownSelect);
    outerDirectionDiv.append(innerDirectionDiv1, directionBtnDiv)
    
    dropdownForm.addEventListener('submit', (e) => listRouteStops(e, schedule))
    mainContainer.append(div, dropdownForm)
}