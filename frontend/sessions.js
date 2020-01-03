const sessionURL = 'http://localhost:3000/login'
let userId

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
    .then(function(user) {
        userId = user.id
        greetUser(user)
    })
}

function greetUser(user) {
    document.getElementById('notification-block').innerText = "Welcome " + user.email
    clearAndReturnMain()
}
