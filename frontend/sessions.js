const sessionURL = `${baseUrl}/login`
let userId
let userHeldInState

document.addEventListener("DOMContentLoaded", () => {
    document.getElementById('log').addEventListener('click', showLogIn)
})

const userInputs = () => {
    const innerDiv1 = document.createElement('div');
    innerDiv1.classList.add('control')

    const emailInput = document.createElement('input');
    emailInput.classList.add('input');
    emailInput.setAttribute('name', 'email');
    emailInput.setAttribute('placeholder', "Enter email address")
    innerDiv1.appendChild(emailInput)

    const innerDiv2 = document.createElement('div')
    innerDiv2.classList.add('control')

    const passwordInput = document.createElement('input')
    passwordInput.classList.add('input');
    passwordInput.type = 'password'
    passwordInput.setAttribute('name', 'password');
    passwordInput.setAttribute('placeholder', "Enter password")
    innerDiv2.appendChild(passwordInput)

    return [innerDiv1, innerDiv2]

}

function showLogIn() {
    const mainContainer = clearAndReturnMain()

    const form = document.createElement('form');
    form.id = 'login-form'

    const outerDiv = document.createElement('div');
    outerDiv.classList.add('field')
    form.appendChild(outerDiv)

    const buttonsDiv = document.createElement('div')
    buttonsDiv.classList.add('control', 'buttons')

    const submitBtn = createSubmit('Log In')
    const newUserBtn = document.createElement('Button')
    newUserBtn.classList.add('button', 'is-primary')
    newUserBtn.innerText = 'Sign Up'
    newUserBtn.type = 'button'
    newUserBtn.addEventListener('click', newUserForm)
    buttonsDiv.append(submitBtn, newUserBtn)

    outerDiv.append(...userInputs(), buttonsDiv)
    form.addEventListener('submit', startSession)
    mainContainer.appendChild(form)
}

function newUserForm() {
    const mainContainer = clearAndReturnMain()

    const form = document.createElement('form')
    form.id = 'sign-up-form'

    const outerDiv = document.createElement('div')
    outerDiv.classList.add('field')
    form.appendChild(outerDiv)

    const passwordConfirmDiv = document.createElement('div')
    passwordConfirmDiv.classList.add('control')
    passwordConfirmInput = document.createElement('input')
    passwordConfirmInput.classList.add('input')
    passwordConfirmInput.type = 'password'
    passwordConfirmInput.setAttribute('name', 'securepassword')
    passwordConfirmInput.setAttribute('placeholder', "Confirm password")
    passwordConfirmDiv.appendChild(passwordConfirmInput)

    const submitBtn = createSubmit('Sign Up')
    const buttonDiv = document.createElement('div')
    buttonDiv.classList.add('control')
    buttonDiv.appendChild(submitBtn)

    outerDiv.append(...userInputs(), passwordConfirmDiv, buttonDiv)

    form.addEventListener('submit', createNewUser)
    mainContainer.appendChild(form)
}

const createSubmit = function(btnText) {
    const submitBtn = document.createElement('button');
    submitBtn.classList.add('button', 'is-primary')
    submitBtn.innerText = btnText;
    submitBtn.type = 'submit';

    return submitBtn
}

class UserFormObject {
    constructor(email, password) {
        this.email = email;
        this.password = password;
    }

    get objectify() {
        return {
            email: this.email,
            password: this.password
        }
    }
}

function startSession(event) {
    event.preventDefault()

    let formObj = new UserFormObject(event.target.email.value, event.target.password.value)
    
    fetch(sessionURL, hostedObj('POST', formObj.objectify))
    .then(response => response.json())
    .then(user => {
        if (user.error) {
            errorNotification(user.message)
        } else {
            userHeldInState = user
            userId = user.id
            const favLink = document.getElementById('favorites')
            favLink.style.display = 'flex'
            greetUser(user)
        }
    })
}

function greetUser(user) {
    document.getElementById('notification-block').innerText = "Welcome " + user.email
    clearAndReturnMain()
}

function displayFavorites(favList) {
    const mainContainer = clearAndReturnMain()
    const listContainer = document.createElement('table')
    listContainer.classList.add('table', 'is-hoverable')
    const containerBody = document.createElement('tbody')
    listContainer.appendChild(containerBody)

    const favElements = favList.map(fav => {
        let row = document.createElement('tr')

        let stopNum = document.createElement('td');
        let stopBox = document.createElement('a')
        stopBox.innerText = fav.permanent_desc
        stopBox.classList.add('stopbox')

        let stopDesc = document.createElement('div')
        stopDesc.classList.add('bus-description')
        stopDesc.innerText = " " + fav.description;
        stopDesc.id = `favorite-${fav.id}`
        stopNum.append(stopBox, stopDesc)

        if (fav.transit_type === 'bus') {
            stopNum.addEventListener('click', (e) => {
                fetch(`${baseUrl}/metro/busstop/${fav.lookup}`)
                .then(response => response.json())
                .then(data => checkForBuses(data, fav.lookup))
            })
        } else {
            stopNum.addEventListener('click', (e) => {
                fetch(`${baseUrl}/metro/station/${fav.lookup}`)
                .then(response => response.json())
                .then(data => {
                    displayTrains(data.Trains, fav.description)
                })
            })
        }
            
        const editFigure = document.createElement('a')
        editFigure.innerText = '✏️'
        editFigure.classList.add('clickable-emoji')
        editFigure.dataset.fav = fav.id
        editFigure.addEventListener('click', (e) => editFav(e.target.dataset.fav))

        const deleteFigure = document.createElement('a')
        deleteFigure.innerText = '🗑️'
        deleteFigure.classList.add('clickable-emoji')
        deleteFigure.dataset.fav = fav.id
        deleteFigure.addEventListener('click', (e) => deleteFavConfirm(e.target.dataset.fav))

        row.append(stopNum, editFigure, deleteFigure)

        return row
    })

    favElements.forEach(elem => {
        containerBody.appendChild(elem)
    })

    mainContainer.appendChild(listContainer)
}

function editFav(favId) {
    const editableFavDescription = document.getElementById(`favorite-${favId}`)
    
    const editDescriptionForm = document.createElement('form')
    editDescriptionForm.classList.add('bus-description')
    editDescriptionForm.addEventListener('submit', saveEdit)
    editDescriptionForm.addEventListener('click', (e) => e.stopPropagation())
    editDescriptionForm.dataset.favId = favId
    
    const descriptionInput = document.createElement('input')
    descriptionInput.classList.add('input','resized-input');
    descriptionInput.setAttribute('name', 'description');
    descriptionInput.setAttribute('maxlength', '60')
    descriptionInput.setAttribute('placeholder', editableFavDescription.innerText)
    
    const descriptionSaveBtn = createSubmit('Save')

    const cancelEditBtn = document.createElement('button')
    cancelEditBtn.innerText = 'Cancel'
    cancelEditBtn.classList.add('button', 'is-warning')
    cancelEditBtn.addEventListener('click', removeEditForm)
    
    editDescriptionForm.append(descriptionInput, descriptionSaveBtn, cancelEditBtn)
    editableFavDescription.setAttribute('hidden', true)
    
    editableFavDescription.insertAdjacentElement('afterend', editDescriptionForm)

    function removeEditForm() {
        formContainer.remove()
        editableFavDescription.removeAttribute('hidden')
    }
}

function saveEdit(e) {
    e.preventDefault()
    fetch(`${favoriteUrl}/${e.target.dataset.favId}`, hostedObj('PATCH', {
        description: e.target.description.value
    }))
    .then(response => response.json())
    .then(updatedFav => {
        if (updatedFav.error) {
            errorNotification(updatedFav.message)
        } else {
            updateFavInState(updatedFav)
            confirmNotification(`${updatedFav.description} has been saved into your favorites.`)
        }
    })
}

function deleteFavConfirm(favId) {
    if (confirm("Are you sure you want to delete this favorite?")) {
        fetch(`${favoriteUrl}/${favId}`, hostedObj('DELETE', null))
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                errorNotification(data.error)
            } else {
                deleteFavFromState(data.id)
            }
        })
    }
}

function deleteFavFromState(favId) {
    const updatedFavs = userHeldInState.favorites.filter(fav => fav.id !== favId)
    userHeldInState.favorites = updatedFavs
    displayFavorites(updatedFavs)
}

function updateFavInState(replacementFav) {
    const oldFavIdx = userHeldInState.favorites.findIndex(fav => fav.id === replacementFav.id)
    userHeldInState.favorites = [...userHeldInState.favorites.slice(0, oldFavIdx), replacementFav, ...userHeldInState.favorites.slice(oldFavIdx + 1)]
    displayFavorites(userHeldInState.favorites)
}

function createNewUser(e) {
    e.preventDefault()

    let formObj = new UserFormObject(e.target.email.value, e.target.password.value)
    let totalObj = {...formObj.objectify, password_confirmation: e.target.securepassword.value}
    
    fetch(`${baseUrl}/users`, hostedObj('POST', {user: totalObj}))
    .then(response => response.json())
    .then(user => {
        if (!user.error) {
            userHeldInState = user
            userId = user.id
            const favLink = document.getElementById('favorites')
            favLink.style.display = 'flex'
            greetUser(user)
        } else {
            errorNotification(user.message)
            document.getElementById('sign-up-form').reset()
        }
    })
}