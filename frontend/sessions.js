const sessionURL = 'http://localhost:3000/login'
let userId
let userHeldInState

document.addEventListener("DOMContentLoaded", () => {
    document.getElementById('log').addEventListener('click', showLogIn)
})

function showLogIn() {
    const mainContainer = clearAndReturnMain()

    const form = document.createElement('form');
    form.id = 'login-form'

    const outerDiv = document.createElement('div');
    outerDiv.classList.add('field')
    form.appendChild(outerDiv)

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


    const innerDiv3 = document.createElement('div')
    innerDiv3.classList.add('control')

    const submitBtn = createSubmit('Log In')
    innerDiv3.appendChild(submitBtn)

    outerDiv.append(innerDiv1, innerDiv2, innerDiv3)
    form.addEventListener('submit', startSession)
    mainContainer.appendChild(form)

}

let createSubmit = function(btnText) {
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
            alert(user.message)
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
        let stopBox = document.createElement('div')
        stopBox.innerText = fav.lookup
        stopBox.classList.add('stopbox')

        let stopDesc = document.createElement('div')
        stopDesc.classList.add('bus-description')
        stopDesc.innerText = " " + fav.description;
        stopDesc.id = `favorite-${fav.id}`
        stopNum.append(stopBox, stopDesc)

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
    
    const descriptionInput = document.createElement('input')
    descriptionInput.classList.add('input','resized-input');
    descriptionInput.setAttribute('name', 'description');
    descriptionInput.setAttribute('maxlength', '60')
    descriptionInput.setAttribute('placeholder', editableFavDescription.innerText)
    
    
    const descriptionSaveBtn = document.createElement('button')
    descriptionSaveBtn.innerText = 'Save'
    descriptionSaveBtn.classList.add('button', 'is-primary')
    descriptionSaveBtn.type = 'submit'

    const cancelEditBtn = document.createElement('button')
    cancelEditBtn.innerText = 'Cancel'
    cancelEditBtn.classList.add('button', 'is-warning')
    cancelEditBtn.addEventListener('click', removeEditForm)
    
    editDescriptionForm.append(descriptionInput, descriptionSaveBtn, cancelEditBtn)
    editableFavDescription.insertAdjacentElement('afterend', editDescriptionForm)
    editableFavDescription.setAttribute('hidden', true)
    
    function removeEditForm() {
        editDescriptionForm.remove()
        editableFavDescription.removeAttribute('hidden')
    }

}


function saveEdit(e) {
    e.preventDefault()
    console.log(e.target.description.value)
}

function deleteFavConfirm(favId) {
    if (confirm("Are you sure you want to delete this favorite?")) {
        console.log('send delete request to server for Id =', favId)
    }
}