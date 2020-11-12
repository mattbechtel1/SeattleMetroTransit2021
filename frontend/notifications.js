function clearAndReturnMain() {
    let mainContainer = document.getElementById('main-container')
    mainContainer.innerHTML = ""
    return mainContainer
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

function displayError(errorMessage) {
    errorNotification(errorMessage)
}

function loaderNotification(...messages) {
    const notificationBlock = clearAndReturnNotification()
    messages.forEach(message => {
        const messageBlock = document.createElement('div')
        messageBlock.classList.add('notification', 'is-warning')
        messageBlock.innerText = message
        messageBlock.appendChild(buildCloseBtn())
        notificationBlock.appendChild(messageBlock)
    })
}

function clearAndReturnNotification() {
    const notificationBlock = document.getElementById('notification-block');
    notificationBlock.classList.remove('notification', 'is-danger', 'is-success', 'is-warning')
    notificationBlock.innerHTML = ''
    return notificationBlock
}