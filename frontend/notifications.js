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