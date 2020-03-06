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

function buildCloseBtn() {
    let closeBtn = document.createElement('button')
    closeBtn.classList.add('delete')
    closeMarker = document.createElement('i')
    closeMarker.classList.add('fas', 'fa-times')
    closeBtn.addEventListener('click', clearAndReturnNotification)
    closeBtn.appendChild(closeMarker)
    return closeBtn
}

const createSubmit = function(btnText) {
    const submitBtn = document.createElement('button');
    submitBtn.classList.add('button', 'is-primary')
    submitBtn.innerText = btnText;
    submitBtn.type = 'submit';

    return submitBtn
}